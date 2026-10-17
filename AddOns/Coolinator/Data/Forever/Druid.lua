local addonTable = select(2, ...)
local class = "DRUID"
if UnitClassBase("player") ~= class then
    return
end
addonTable.Data.Spells[class] = {
  [1] = {
    ['spells'] = {
      [1] = 5185,
      [2] = 5186,
      [3] = 5187,
      [4] = 5188,
      [5] = 5189,
      [6] = 6778,
      [7] = 8903,
      [8] = 9758,
      [9] = 9888,
      [10] = 9889
    },
    ['name'] = 'Healing Touch',
    ['isRanked'] = true
  },
  [2] = {
    ['spells'] = {
      [1] = 5176,
      [2] = 5177,
      [3] = 5178,
      [4] = 5179,
      [5] = 5180,
      [6] = 6780,
      [7] = 8905,
      [8] = 9912
    },
    ['name'] = 'Wrath',
    ['isRanked'] = true
  },
  [3] = {
    ['spells'] = {
      [1] = 1126,
      [2] = 5232,
      [3] = 6756,
      [4] = 5234,
      [5] = 8907,
      [6] = 9884,
      [7] = 9885
    },
    ['name'] = 'Mark of the Wild',
    ['isRanked'] = true
  },
  [4] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8921,
      [2] = 8924,
      [3] = 8925,
      [4] = 8926,
      [5] = 8927,
      [6] = 8928,
      [7] = 8929,
      [8] = 9833,
      [9] = 9834,
      [10] = 9835
    },
    ['name'] = 'Moonfire',
    ['isRanked'] = true
  },
  [5] = {
    ['spells'] = {
      [1] = 774,
      [2] = 1058,
      [3] = 1430,
      [4] = 2090,
      [5] = 2091,
      [6] = 3627,
      [7] = 8910,
      [8] = 9839,
      [9] = 9840,
      [10] = 9841
    },
    ['name'] = 'Rejuvenation',
    ['isRanked'] = true
  },
  [6] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 467,
      [2] = 782,
      [3] = 1075,
      [4] = 8914,
      [5] = 9756,
      [6] = 9910
    },
    ['name'] = 'Thorns',
    ['isRanked'] = true
  },
  [7] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 339,
      [2] = 1062,
      [3] = 5195,
      [4] = 5196,
      [5] = 9852,
      [6] = 9853
    },
    ['name'] = 'Entangling Roots',
    ['isRanked'] = true
  },
  [8] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 99,
      [2] = 1735,
      [3] = 9490,
      [4] = 9747,
      [5] = 9898
    },
    ['name'] = 'Demoralizing Roar',
    ['isRanked'] = true
  },
  [9] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 16689,
      [2] = 16810,
      [3] = 16811,
      [4] = 16812,
      [5] = 16813,
      [6] = 17329
    },
    ['name'] = 'Nature\'s Grasp',
    ['isRanked'] = true
  },
  [10] = {
    ['spells'] = {
      [1] = 5229
    },
    ['name'] = 'Enrage',
    ['isRanked'] = false
  },
  [11] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 8936,
      [2] = 8938,
      [3] = 8939,
      [4] = 8940,
      [5] = 8941,
      [6] = 9750,
      [7] = 9856,
      [8] = 9857,
      [9] = 9858
    },
    ['name'] = 'Regrowth',
    ['isRanked'] = true
  },
  [12] = {
    ['spells'] = {
      [1] = 437138,
      [2] = 1237948,
      [3] = 1237949,
      [4] = 1237950,
      [5] = 1237951
    },
    ['name'] = 'Revive',
    ['isRanked'] = true
  },
  [13] = {
    ['spells'] = {
      [1] = 5211,
      [2] = 6798,
      [3] = 8983
    },
    ['name'] = 'Bash',
    ['isRanked'] = true
  },
  [14] = {
    ['spells'] = {
      [1] = 779,
      [2] = 780,
      [3] = 769,
      [4] = 9754,
      [5] = 9908
    },
    ['name'] = 'Swipe',
    ['isRanked'] = true
  },
  [15] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 770,
      [2] = 778,
      [3] = 9749,
      [4] = 9907
    },
    ['name'] = 'Faerie Fire',
    ['isRanked'] = true
  },
  [16] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 2637,
      [2] = 18657,
      [3] = 18658
    },
    ['name'] = 'Hibernate',
    ['isRanked'] = true
  },
  [17] = {
    ['spells'] = {
      [1] = 6807,
      [2] = 6808,
      [3] = 6809,
      [4] = 8972,
      [5] = 9745,
      [6] = 9880,
      [7] = 9881
    },
    ['name'] = 'Maul',
    ['isRanked'] = true
  },
  [18] = {
    ['spells'] = {
      [1] = 16864
    },
    ['name'] = 'Omen of Clarity',
    ['isRanked'] = false
  },
  [19] = {
    ['spells'] = {
      [1] = 20484,
      [2] = 20739,
      [3] = 20742,
      [4] = 20747,
      [5] = 20748
    },
    ['name'] = 'Rebirth',
    ['isRanked'] = true
  },
  [20] = {
    ['spells'] = {
      [1] = 5221,
      [2] = 6800,
      [3] = 8992,
      [4] = 9829,
      [5] = 9830
    },
    ['name'] = 'Shred',
    ['isRanked'] = true
  },
  [21] = {
    ['spells'] = {
      [1] = 2912,
      [2] = 8949,
      [3] = 8950,
      [4] = 8951,
      [5] = 9875,
      [6] = 9876
    },
    ['name'] = 'Starfire',
    ['isRanked'] = true
  },
  [22] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 2908,
      [2] = 8955,
      [3] = 9901
    },
    ['name'] = 'Soothe Animal',
    ['isRanked'] = true
  },
  [23] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1822,
      [2] = 1823,
      [3] = 1824,
      [4] = 9904
    },
    ['name'] = 'Rake',
    ['isRanked'] = true
  },
  [24] = {
    ['spells'] = {
      [1] = 2782
    },
    ['name'] = 'Remove Curse',
    ['isRanked'] = false
  },
  [25] = {
    ['spells'] = {
      [1] = 2893
    },
    ['name'] = 'Abolish Poison',
    ['isRanked'] = false
  },
  [26] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1850,
      [2] = 9821
    },
    ['name'] = 'Dash',
    ['isRanked'] = true
  },
  [27] = {
    ['spells'] = {
      [1] = 5209
    },
    ['name'] = 'Challenging Roar',
    ['isRanked'] = false
  },
  [28] = {
    ['spells'] = {
      [1] = 1082,
      [2] = 3029,
      [3] = 5201,
      [4] = 9849,
      [5] = 9850
    },
    ['name'] = 'Claw',
    ['isRanked'] = true
  },
  [29] = {
    ['spells'] = {
      [1] = 8998,
      [2] = 9000,
      [3] = 9892
    },
    ['name'] = 'Cower',
    ['isRanked'] = true
  },
  [30] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1079,
      [2] = 9492,
      [3] = 9493,
      [4] = 9752,
      [5] = 9894,
      [6] = 9896
    },
    ['name'] = 'Rip',
    ['isRanked'] = true
  },
  [31] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 5570,
      [2] = 24974,
      [3] = 24975,
      [4] = 24976,
      [5] = 24977
    },
    ['name'] = 'Insect Swarm',
    ['isRanked'] = true
  },
  [32] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 740,
      [2] = 8918,
      [3] = 9862,
      [4] = 9863
    },
    ['name'] = 'Tranquility',
    ['isRanked'] = true
  },
  [33] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 783
    },
    ['name'] = 'Travel Form',
    ['isRanked'] = false
  },
  [34] = {
    ['spells'] = {
      [1] = 22568,
      [2] = 22827,
      [3] = 22828,
      [4] = 22829
    },
    ['name'] = 'Ferocious Bite',
    ['isRanked'] = true
  },
  [35] = {
    ['spells'] = {
      [1] = 6785,
      [2] = 6787,
      [3] = 9866,
      [4] = 9867
    },
    ['name'] = 'Ravage',
    ['isRanked'] = true
  },
  [36] = {
    ['spells'] = {
      [1] = 5225
    },
    ['name'] = 'Track Humanoids',
    ['isRanked'] = false
  },
  [37] = {
    ['spells'] = {
      [1] = 22842,
      [2] = 22845
    },
    ['name'] = 'Frenzied Regeneration',
    ['isRanked'] = false
  },
  [38] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 9005,
      [2] = 9823,
      [3] = 9827
    },
    ['name'] = 'Pounce',
    ['isRanked'] = true
  },
  [39] = {
    ['spells'] = {
      [1] = 407995,
      [2] = 1238069,
      [3] = 1238070,
      [4] = 1238073
    },
    ['name'] = 'Primal Bite',
    ['isRanked'] = true
  },
  [40] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 9634
    },
    ['name'] = 'Dire Bear Form',
    ['isRanked'] = false
  },
  [41] = {
    ['spells'] = {
      [1] = 20719
    },
    ['name'] = 'Feline Grace',
    ['isRanked'] = false
  },
  [42] = {
    ['spells'] = {
      [1] = 16914,
      [2] = 17401,
      [3] = 17402
    },
    ['name'] = 'Hurricane',
    ['isRanked'] = true
  },
  [43] = {
    ['spells'] = {
      [1] = 29166
    },
    ['name'] = 'Innervate',
    ['isRanked'] = false
  },
  [44] = {
    ['spells'] = {
      [1] = 5215,
      [2] = 6783,
      [3] = 9913
    },
    ['name'] = 'Prowl',
    ['isRanked'] = true
  },
  [45] = {
    ['spells'] = {
      [1] = 414644,
      [2] = 1235826,
      [3] = 1235827,
      [4] = 414647
    },
    ['name'] = 'Lacerate',
    ['isRanked'] = true
  },
  [46] = {
    ['spells'] = {
      [1] = 22812
    },
    ['name'] = 'Barkskin',
    ['isRanked'] = false
  },
  [47] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 408120,
      [2] = 1238214,
      [3] = 1238215
    },
    ['name'] = 'Wild Growth',
    ['isRanked'] = true
  },
  [48] = {
    ['spells'] = {
      [1] = 18562
    },
    ['name'] = 'Swiftmend',
    ['isRanked'] = false
  },
  [49] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 17116
    },
    ['name'] = 'Nature\'s Swiftness',
    ['isRanked'] = false
  },
  [50] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 24858
    },
    ['name'] = 'Moonkin Form',
    ['isRanked'] = false
  },
  [51] = {
    ['spells'] = {
      [1] = 1238122,
      [2] = 19675,
      [3] = 414923
    },
    ['name'] = 'Feral Charge',
    ['isRanked'] = false
  },
  [52] = {
    ['spells'] = {
      [1] = 1322605
    },
    ['name'] = 'Shifting Power',
    ['isRanked'] = false
  },
  [53] = {
    ['spells'] = {
      [1] = 417141
    },
    ['name'] = 'Berserk',
    ['isRanked'] = false
  },
  [54] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 16870
    },
    ['name'] = 'Clearcasting',
    ['isRanked'] = false
  },
  [55] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 408255
    },
    ['name'] = 'Eclipse',
    ['isRanked'] = false
  },
  [56] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 16886
    },
    ['name'] = 'Nature\'s Grace',
    ['isRanked'] = false
  },
  [57] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 16922
    },
    ['name'] = 'Starfire Stun',
    ['isRanked'] = false
  },
  [58] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 5215,
      [2] = 6783,
      [3] = 9913
    },
    ['name'] = 'Prowl',
    ['isRanked'] = true
  },
  [59] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 414647,
      [2] = 1235826,
      [3] = 1235827
    },
    ['name'] = 'Lacerate',
    ['isRanked'] = true
  },
  [60] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 22845
    },
    ['name'] = 'Frenzied Regeneration',
    ['isRanked'] = false
  },
  [61] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 19675,
      [2] = 414923
    },
    ['name'] = 'Feral Charge',
    ['isRanked'] = false
  },
  [62] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1324487,
      [2] = 1324488,
      [3] = 1324490
    },
    ['name'] = 'Bash',
    ['isRanked'] = false
  },
  [63] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1126,
      [2] = 5232,
      [3] = 5287,
      [4] = 5234,
      [5] = 8907,
      [6] = 9884,
      [7] = 9885
    },
    ['name'] = 'Mark of the Wild',
    ['isRanked'] = true
  },
  [64] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 21849,
      [2] = 21850
    },
    ['name'] = 'Gift of the Wild',
    ['isRanked'] = true
  },
  [65] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 774,
      [2] = 1058,
      [3] = 1430,
      [4] = 2090,
      [5] = 2091,
      [6] = 3627,
      [7] = 8910,
      [8] = 9839,
      [9] = 9840,
      [10] = 9841,
      [11] = 25299
    },
    ['name'] = 'Rejuvenation',
    ['isRanked'] = true
  },
  [66] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 5487
    },
    ['name'] = 'Bear Form',
    ['isRanked'] = false
  },
  [67] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 768
    },
    ['name'] = 'Cat Form',
    ['isRanked'] = false
  },
  [68] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1066
    },
    ['name'] = 'Aquatic Form',
    ['isRanked'] = false
  },
  [69] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 24932
    },
    ['name'] = 'Leader of the Pack',
    ['isRanked'] = false
  },
  [70] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 24907
    },
    ['name'] = 'Moonkin Aura',
    ['isRanked'] = false
  }
}
