local addonTable = select(2, ...)
local class = "SHAMAN"
if UnitClassBase("player") ~= class then
    return
end
addonTable.Data.Spells[class] = {
  [1] = {
    ['spells'] = {
      [1] = 331,
      [2] = 332,
      [3] = 547,
      [4] = 913,
      [5] = 939,
      [6] = 959,
      [7] = 8005,
      [8] = 10395,
      [9] = 10396
    },
    ['name'] = 'Healing Wave',
    ['isRanked'] = true
  },
  [2] = {
    ['spells'] = {
      [1] = 403,
      [2] = 529,
      [3] = 548,
      [4] = 915,
      [5] = 943,
      [6] = 6041,
      [7] = 10391,
      [8] = 10392,
      [9] = 15207,
      [10] = 15208
    },
    ['name'] = 'Lightning Bolt',
    ['isRanked'] = true
  },
  [3] = {
    ['spells'] = {
      [1] = 8017,
      [2] = 8018,
      [3] = 8019,
      [4] = 10399,
      [5] = 16314,
      [6] = 16315,
      [7] = 16316
    },
    ['name'] = 'Rockbiter Weapon',
    ['isRanked'] = true
  },
  [4] = {
    ['spells'] = {
      [1] = 8042,
      [2] = 8044,
      [3] = 8045,
      [4] = 8046,
      [5] = 10412,
      [6] = 10413,
      [7] = 10414
    },
    ['name'] = 'Earth Shock',
    ['isRanked'] = true
  },
  [5] = {
    ['spells'] = {
      [1] = 2484
    },
    ['name'] = 'Earthbind Totem',
    ['isRanked'] = false
  },
  [6] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 324,
      [2] = 325,
      [3] = 905,
      [4] = 945,
      [5] = 8134,
      [6] = 10431,
      [7] = 10432
    },
    ['name'] = 'Lightning Shield',
    ['isRanked'] = true
  },
  [7] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 5730,
      [2] = 6390,
      [3] = 6391,
      [4] = 6392,
      [5] = 10427,
      [6] = 10428
    },
    ['name'] = 'Stoneclaw Totem',
    ['isRanked'] = true
  },
  [8] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8050,
      [2] = 8052,
      [3] = 8053,
      [4] = 10447,
      [5] = 10448,
      [6] = 29228
    },
    ['name'] = 'Flame Shock',
    ['isRanked'] = true
  },
  [9] = {
    ['spells'] = {
      [1] = 8024,
      [2] = 8027,
      [3] = 8030,
      [4] = 16339,
      [5] = 16341,
      [6] = 16342
    },
    ['name'] = 'Flametongue Weapon',
    ['isRanked'] = true
  },
  [10] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8075,
      [2] = 8160,
      [3] = 8161,
      [4] = 10442,
      [5] = 25361
    },
    ['name'] = 'Strength of Earth Totem',
    ['isRanked'] = true
  },
  [11] = {
    ['spells'] = {
      [1] = 2008,
      [2] = 20609,
      [3] = 20610,
      [4] = 20776,
      [5] = 20777
    },
    ['name'] = 'Ancestral Spirit',
    ['isRanked'] = true
  },
  [12] = {
    ['spells'] = {
      [1] = 408341,
      [2] = 408342,
      [3] = 408343,
      [4] = 408344,
      [5] = 408345
    },
    ['name'] = 'Fire Nova',
    ['isRanked'] = true
  },
  [13] = {
    ['spells'] = {
      [1] = 370,
      [2] = 8012
    },
    ['name'] = 'Purge',
    ['isRanked'] = true
  },
  [14] = {
    ['spells'] = {
      [1] = 8071,
      [2] = 8154,
      [3] = 8155,
      [4] = 10406,
      [5] = 10407,
      [6] = 10408
    },
    ['name'] = 'Stoneskin Totem',
    ['isRanked'] = true
  },
  [15] = {
    ['spells'] = {
      [1] = 526
    },
    ['name'] = 'Cure Poison',
    ['isRanked'] = false
  },
  [16] = {
    ['spells'] = {
      [1] = 8143
    },
    ['name'] = 'Tremor Totem',
    ['isRanked'] = false
  },
  [17] = {
    ['spells'] = {
      [1] = 66842
    },
    ['name'] = 'Call of the Elements',
    ['isRanked'] = false
  },
  [18] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8056,
      [2] = 8058,
      [3] = 10472,
      [4] = 10473
    },
    ['name'] = 'Frost Shock',
    ['isRanked'] = true
  },
  [19] = {
    ['spells'] = {
      [1] = 8033,
      [2] = 8038,
      [3] = 10456,
      [4] = 16355,
      [5] = 16356
    },
    ['name'] = 'Frostbrand Weapon',
    ['isRanked'] = true
  },
  [20] = {
    ['spells'] = {
      [1] = 2645
    },
    ['name'] = 'Ghost Wolf',
    ['isRanked'] = false
  },
  [21] = {
    ['spells'] = {
      [1] = 8004,
      [2] = 8008,
      [3] = 8010,
      [4] = 10466,
      [5] = 10467,
      [6] = 10468
    },
    ['name'] = 'Lesser Healing Wave',
    ['isRanked'] = true
  },
  [22] = {
    ['spells'] = {
      [1] = 3599,
      [2] = 6363,
      [3] = 6364,
      [4] = 6365,
      [5] = 10437,
      [6] = 10438
    },
    ['name'] = 'Searing Totem',
    ['isRanked'] = true
  },
  [23] = {
    ['spells'] = {
      [1] = 36936
    },
    ['name'] = 'Totemic Recall',
    ['isRanked'] = false
  },
  [24] = {
    ['spells'] = {
      [1] = 2870
    },
    ['name'] = 'Cure Disease',
    ['isRanked'] = false
  },
  [25] = {
    ['spells'] = {
      [1] = 8166
    },
    ['name'] = 'Poison Cleansing Totem',
    ['isRanked'] = false
  },
  [26] = {
    ['spells'] = {
      [1] = 437009
    },
    ['name'] = 'Totemic Projection',
    ['isRanked'] = false
  },
  [27] = {
    ['spells'] = {
      [1] = 131
    },
    ['name'] = 'Water Breathing',
    ['isRanked'] = false
  },
  [28] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8181,
      [2] = 10478,
      [3] = 10479
    },
    ['name'] = 'Frost Resistance Totem',
    ['isRanked'] = true
  },
  [29] = {
    ['spells'] = {
      [1] = 6196
    },
    ['name'] = 'Far Sight',
    ['isRanked'] = false
  },
  [30] = {
    ['spells'] = {
      [1] = 8190,
      [2] = 10585,
      [3] = 10586,
      [4] = 10587
    },
    ['name'] = 'Magma Totem',
    ['isRanked'] = true
  },
  [31] = {
    ['spells'] = {
      [1] = 5675,
      [2] = 10495,
      [3] = 10496,
      [4] = 10497
    },
    ['name'] = 'Mana Spring Totem',
    ['isRanked'] = true
  },
  [32] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8184,
      [2] = 10537,
      [3] = 10538
    },
    ['name'] = 'Fire Resistance Totem',
    ['isRanked'] = true
  },
  [33] = {
    ['spells'] = {
      [1] = 8227,
      [2] = 8249,
      [3] = 10526,
      [4] = 16387
    },
    ['name'] = 'Flametongue Totem',
    ['isRanked'] = true
  },
  [34] = {
    ['spells'] = {
      [1] = 546
    },
    ['name'] = 'Water Walking',
    ['isRanked'] = false
  },
  [35] = {
    ['spells'] = {
      [1] = 556
    },
    ['name'] = 'Astral Recall',
    ['isRanked'] = false
  },
  [36] = {
    ['spells'] = {
      [1] = 66843
    },
    ['name'] = 'Call of the Ancestors',
    ['isRanked'] = false
  },
  [37] = {
    ['spells'] = {
      [1] = 8177
    },
    ['name'] = 'Grounding Totem',
    ['isRanked'] = false
  },
  [38] = {
    ['spells'] = {
      [1] = 5394,
      [2] = 6375,
      [3] = 6377,
      [4] = 10462,
      [5] = 10463
    },
    ['name'] = 'Healing Stream Totem',
    ['isRanked'] = true
  },
  [39] = {
    ['spells'] = {
      [1] = 10595,
      [2] = 10600,
      [3] = 10601
    },
    ['name'] = 'Nature Resistance Totem',
    ['isRanked'] = true
  },
  [40] = {
    ['spells'] = {
      [1] = 20608
    },
    ['name'] = 'Reincarnation',
    ['isRanked'] = false
  },
  [41] = {
    ['spells'] = {
      [1] = 8232,
      [2] = 8235,
      [3] = 10486,
      [4] = 16362
    },
    ['name'] = 'Windfury Weapon',
    ['isRanked'] = true
  },
  [42] = {
    ['spells'] = {
      [1] = 421,
      [2] = 930,
      [3] = 2860,
      [4] = 10605
    },
    ['name'] = 'Chain Lightning',
    ['isRanked'] = true
  },
  [43] = {
    ['spells'] = {
      [1] = 8512,
      [2] = 10613,
      [3] = 10614
    },
    ['name'] = 'Windfury Totem',
    ['isRanked'] = true
  },
  [44] = {
    ['spells'] = {
      [1] = 6495
    },
    ['name'] = 'Sentry Totem',
    ['isRanked'] = false
  },
  [45] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 15107,
      [2] = 15111,
      [3] = 15112
    },
    ['name'] = 'Windwall Totem',
    ['isRanked'] = true
  },
  [46] = {
    ['spells'] = {
      [1] = 8170
    },
    ['name'] = 'Disease Cleansing Totem',
    ['isRanked'] = false
  },
  [47] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 16190,
      [2] = 17354,
      [3] = 17359,
      [4] = 1325256
    },
    ['name'] = 'Mana Tide Totem',
    ['isRanked'] = true
  },
  [48] = {
    ['spells'] = {
      [1] = 66844
    },
    ['name'] = 'Call of the Spirits',
    ['isRanked'] = false
  },
  [49] = {
    ['spells'] = {
      [1] = 1064,
      [2] = 10622,
      [3] = 10623
    },
    ['name'] = 'Chain Heal',
    ['isRanked'] = true
  },
  [50] = {
    ['spells'] = {
      [1] = 408490,
      [2] = 1238299,
      [3] = 1238300,
      [4] = 1326047
    },
    ['name'] = 'Lava Burst',
    ['isRanked'] = true
  },
  [51] = {
    ['spells'] = {
      [1] = 8737
    },
    ['name'] = 'Mail',
    ['isRanked'] = false
  },
  [52] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8835,
      [2] = 10627,
      [3] = 25359
    },
    ['name'] = 'Grace of Air Totem',
    ['isRanked'] = true
  },
  [53] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 408521,
      [2] = 1239242,
      [3] = 1239243
    },
    ['name'] = 'Riptide',
    ['isRanked'] = true
  },
  [54] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 16188
    },
    ['name'] = 'Nature\'s Swiftness',
    ['isRanked'] = false
  },
  [55] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 408510
    },
    ['name'] = 'Water Shield',
    ['isRanked'] = false
  },
  [56] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 425336
    },
    ['name'] = 'Rage of the Farseer',
    ['isRanked'] = false
  },
  [57] = {
    ['spells'] = {
      [1] = 17364
    },
    ['name'] = 'Stormstrike',
    ['isRanked'] = false
  },
  [58] = {
    ['spells'] = {
      [1] = 16166
    },
    ['name'] = 'Elemental Mastery',
    ['isRanked'] = false
  },
  [59] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8836,
      [2] = 10626,
      [3] = 25360
    },
    ['name'] = 'Grace of Air',
    ['isRanked'] = true
  },
  [60] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8076,
      [2] = 8162,
      [3] = 8163,
      [4] = 10441,
      [5] = 25362
    },
    ['name'] = 'Strength of Earth',
    ['isRanked'] = true
  },
  [61] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8185,
      [2] = 10534,
      [3] = 10535
    },
    ['name'] = 'Fire Resistance',
    ['isRanked'] = true
  },
  [62] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8172
    },
    ['name'] = 'Disease Cleansing Totem Passive',
    ['isRanked'] = false
  },
  [63] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8182,
      [2] = 10476,
      [3] = 10477
    },
    ['name'] = 'Frost Resistance',
    ['isRanked'] = true
  },
  [64] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8179
    },
    ['name'] = 'Grounding Totem Passive',
    ['isRanked'] = false
  },
  [65] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 15108,
      [2] = 15109,
      [3] = 15110
    },
    ['name'] = 'Windwall',
    ['isRanked'] = true
  },
  [66] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8167
    },
    ['name'] = 'Poison Cleansing Totem Passive',
    ['isRanked'] = false
  },
  [67] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 5677,
      [2] = 10491,
      [3] = 10493,
      [4] = 10494
    },
    ['name'] = 'Mana Spring',
    ['isRanked'] = true
  },
  [68] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 8145
    },
    ['name'] = 'Tremor Totem Passive',
    ['isRanked'] = false
  },
  [69] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 6474
    },
    ['name'] = 'Earthbind Totem Passive',
    ['isRanked'] = false
  },
  [70] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 16191,
      [2] = 17355,
      [3] = 17360,
      [4] = 1325257
    },
    ['name'] = 'Mana Tide',
    ['isRanked'] = true
  },
  [71] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 30160,
      [2] = 30165
    },
    ['name'] = 'Elemental Devastation',
    ['isRanked'] = false
  },
  [72] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 1238289
    },
    ['name'] = 'Earthbound',
    ['isRanked'] = false
  },
  [73] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 2645,
      [2] = 1238640
    },
    ['name'] = 'Ghost Wolf',
    ['isRanked'] = false
  },
  [74] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1223031
    },
    ['name'] = 'Improved Stormstrike',
    ['isRanked'] = false
  },
  [75] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 16256
    },
    ['name'] = 'Flurry',
    ['isRanked'] = false
  },
  [76] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 16246
    },
    ['name'] = 'Clearcasting',
    ['isRanked'] = false
  },
  [77] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 16177
    },
    ['name'] = 'Ancestral Fortitude',
    ['isRanked'] = false
  },
  [78] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 5678,
      [2] = 10495,
      [3] = 10496,
      [4] = 10497
    },
    ['name'] = 'Mana Spring Totem',
    ['isRanked'] = true
  },
  [79] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 5677,
      [2] = 10491,
      [3] = 10493,
      [4] = 10494
    },
    ['name'] = 'Mana Spring',
    ['isRanked'] = true
  },
  [80] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 15108,
      [2] = 15109,
      [3] = 15110
    },
    ['name'] = 'Windwall',
    ['isRanked'] = true
  },
  [81] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8179
    },
    ['name'] = 'Grounding Totem Passive',
    ['isRanked'] = false
  },
  [82] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8178
    },
    ['name'] = 'Grounding Totem',
    ['isRanked'] = true
  },
  [83] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8182,
      [2] = 10476,
      [3] = 10477
    },
    ['name'] = 'Frost Resistance',
    ['isRanked'] = true
  },
  [84] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8185,
      [2] = 10534,
      [3] = 10535
    },
    ['name'] = 'Fire Resistance',
    ['isRanked'] = true
  },
  [85] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8512,
      [2] = 10609,
      [3] = 10612
    },
    ['name'] = 'Windfury Totem',
    ['isRanked'] = true
  },
  [86] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8076,
      [2] = 8162,
      [3] = 8163,
      [4] = 10441,
      [5] = 25362
    },
    ['name'] = 'Strength of Earth',
    ['isRanked'] = true
  },
  [87] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8836,
      [2] = 10626,
      [3] = 25360
    },
    ['name'] = 'Grace of Air',
    ['isRanked'] = true
  },
  [88] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 8230,
      [2] = 8250,
      [3] = 10521,
      [4] = 16387
    },
    ['name'] = 'Flametongue Totem',
    ['isRanked'] = true
  },
  [89] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 16191,
      [2] = 17355,
      [3] = 17360,
      [4] = 1325257
    },
    ['name'] = 'Mana Tide',
    ['isRanked'] = true
  }
}
