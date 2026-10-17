local addonTable = select(2, ...)
local class = "MAGE"
if UnitClassBase("player") ~= class then
    return
end
addonTable.Data.Spells[class] = {
  [1] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 168,
      [2] = 7300,
      [3] = 7301
    },
    ['name'] = 'Frost Armor',
    ['isRanked'] = true
  },
  [2] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 133,
      [2] = 143,
      [3] = 145,
      [4] = 3140,
      [5] = 8400,
      [6] = 8401,
      [7] = 8402,
      [8] = 10148,
      [9] = 10149,
      [10] = 10150,
      [11] = 10151
    },
    ['name'] = 'Fireball',
    ['isRanked'] = true
  },
  [3] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1459,
      [2] = 1460,
      [3] = 1461,
      [4] = 10156,
      [5] = 10157
    },
    ['name'] = 'Arcane Intellect',
    ['isRanked'] = true
  },
  [4] = {
    ['spells'] = {
      [1] = 5504,
      [2] = 5505,
      [3] = 5506,
      [4] = 6127,
      [5] = 10138,
      [6] = 10139
    },
    ['name'] = 'Conjure Water',
    ['isRanked'] = true
  },
  [5] = {
    ['spells'] = {
      [1] = 116,
      [2] = 205,
      [3] = 837,
      [4] = 7322,
      [5] = 8406,
      [6] = 8407,
      [7] = 8408,
      [8] = 10179,
      [9] = 10180,
      [10] = 10181
    },
    ['name'] = 'Frostbolt',
    ['isRanked'] = true
  },
  [6] = {
    ['spells'] = {
      [1] = 1296017
    },
    ['name'] = 'Comprehend Scroll',
    ['isRanked'] = false
  },
  [7] = {
    ['spells'] = {
      [1] = 587,
      [2] = 597,
      [3] = 990,
      [4] = 6129,
      [5] = 10144,
      [6] = 10145
    },
    ['name'] = 'Conjure Food',
    ['isRanked'] = true
  },
  [8] = {
    ['spells'] = {
      [1] = 2136,
      [2] = 2137,
      [3] = 2138,
      [4] = 8412,
      [5] = 8413,
      [6] = 10197,
      [7] = 10199
    },
    ['name'] = 'Fire Blast',
    ['isRanked'] = true
  },
  [9] = {
    ['spells'] = {
      [1] = 5143,
      [2] = 5144,
      [3] = 5145,
      [4] = 8416,
      [5] = 8417,
      [6] = 10211,
      [7] = 10212
    },
    ['name'] = 'Arcane Missiles',
    ['isRanked'] = true
  },
  [10] = {
    ['spells'] = {
      [1] = 118,
      [2] = 12824,
      [3] = 12825,
      [4] = 12826
    },
    ['name'] = 'Polymorph',
    ['isRanked'] = true
  },
  [11] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 122,
      [2] = 865,
      [3] = 6131,
      [4] = 10230
    },
    ['name'] = 'Frost Nova',
    ['isRanked'] = true
  },
  [12] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 604,
      [2] = 8450,
      [3] = 8451,
      [4] = 10173,
      [5] = 10174
    },
    ['name'] = 'Dampen Magic',
    ['isRanked'] = true
  },
  [13] = {
    ['spells'] = {
      [1] = 130
    },
    ['name'] = 'Slow Fall',
    ['isRanked'] = false
  },
  [14] = {
    ['spells'] = {
      [1] = 1449,
      [2] = 8437,
      [3] = 8438,
      [4] = 8439,
      [5] = 10201,
      [6] = 10202
    },
    ['name'] = 'Arcane Explosion',
    ['isRanked'] = true
  },
  [15] = {
    ['spells'] = {
      [1] = 2120,
      [2] = 2121,
      [3] = 8422,
      [4] = 8423,
      [5] = 10215,
      [6] = 10216
    },
    ['name'] = 'Flamestrike',
    ['isRanked'] = true
  },
  [16] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1008,
      [2] = 8455,
      [3] = 10169,
      [4] = 10170
    },
    ['name'] = 'Amplify Magic',
    ['isRanked'] = true
  },
  [17] = {
    ['spells'] = {
      [1] = 475
    },
    ['name'] = 'Remove Lesser Curse',
    ['isRanked'] = false
  },
  [18] = {
    ['spells'] = {
      [1] = 1953
    },
    ['name'] = 'Blink',
    ['isRanked'] = false
  },
  [19] = {
    ['spells'] = {
      [1] = 10,
      [2] = 6141,
      [3] = 8427,
      [4] = 10185,
      [5] = 10186,
      [6] = 10187
    },
    ['name'] = 'Blizzard',
    ['isRanked'] = true
  },
  [20] = {
    ['spells'] = {
      [1] = 12051
    },
    ['name'] = 'Evocation',
    ['isRanked'] = false
  },
  [21] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 543,
      [2] = 8457,
      [3] = 8458,
      [4] = 10223,
      [5] = 10225
    },
    ['name'] = 'Fire Ward',
    ['isRanked'] = true
  },
  [22] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1463,
      [2] = 8494,
      [3] = 8495,
      [4] = 10191,
      [5] = 10192,
      [6] = 10193
    },
    ['name'] = 'Mana Shield',
    ['isRanked'] = true
  },
  [23] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 6143,
      [2] = 8461,
      [3] = 8462,
      [4] = 10177,
      [5] = 28609
    },
    ['name'] = 'Frost Ward',
    ['isRanked'] = true
  },
  [24] = {
    ['spells'] = {
      [1] = 2948,
      [2] = 8444,
      [3] = 8445,
      [4] = 8446,
      [5] = 10205,
      [6] = 10206,
      [7] = 10207
    },
    ['name'] = 'Scorch',
    ['isRanked'] = true
  },
  [25] = {
    ['spells'] = {
      [1] = 2139
    },
    ['name'] = 'Counterspell',
    ['isRanked'] = false
  },
  [26] = {
    ['spells'] = {
      [1] = 1326053,
      [2] = 1326054,
      [3] = 1326055
    },
    ['name'] = 'Frost Blast',
    ['isRanked'] = true
  },
  [27] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 11366,
      [2] = 12505,
      [3] = 12522,
      [4] = 12523,
      [5] = 12524,
      [6] = 12525,
      [7] = 12526,
      [8] = 18809
    },
    ['name'] = 'Pyroblast',
    ['isRanked'] = true
  },
  [28] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 120,
      [2] = 8492,
      [3] = 10159,
      [4] = 10160,
      [5] = 10161
    },
    ['name'] = 'Cone of Cold',
    ['isRanked'] = true
  },
  [29] = {
    ['spells'] = {
      [1] = 759
    },
    ['name'] = 'Conjure Mana Agate',
    ['isRanked'] = false
  },
  [30] = {
    ['spells'] = {
      [1] = 1312002,
      [2] = 400640,
      [3] = 1240044,
      [4] = 1240045,
      [5] = 1240046,
      [6] = 1240047
    },
    ['name'] = 'Ice Lance',
    ['isRanked'] = true
  },
  [31] = {
    ['spells'] = {
      [1] = 400574,
      [2] = 1239696,
      [3] = 1239697,
      [4] = 1239699,
      [5] = 1239700
    },
    ['name'] = 'Arcane Blast',
    ['isRanked'] = true
  },
  [32] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 7302,
      [2] = 7320,
      [3] = 10219,
      [4] = 10220
    },
    ['name'] = 'Ice Armor',
    ['isRanked'] = true
  },
  [33] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 6117,
      [2] = 22782,
      [3] = 22783
    },
    ['name'] = 'Mage Armor',
    ['isRanked'] = true
  },
  [34] = {
    ['spells'] = {
      [1] = 1326079,
      [2] = 1326080,
      [3] = 1326081,
      [4] = 1326082
    },
    ['name'] = 'Arcane Wrath',
    ['isRanked'] = true
  },
  [35] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 11113,
      [2] = 13018,
      [3] = 13019,
      [4] = 13020,
      [5] = 13021
    },
    ['name'] = 'Blast Wave',
    ['isRanked'] = true
  },
  [36] = {
    ['spells'] = {
      [1] = 3552
    },
    ['name'] = 'Conjure Mana Jade',
    ['isRanked'] = false
  },
  [37] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 401502,
      [2] = 1237312,
      [3] = 1237313
    },
    ['name'] = 'Frostfire Bolt',
    ['isRanked'] = true
  },
  [38] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 11426,
      [2] = 13031,
      [3] = 13032,
      [4] = 13033
    },
    ['name'] = 'Ice Barrier',
    ['isRanked'] = true
  },
  [39] = {
    ['spells'] = {
      [1] = 10053
    },
    ['name'] = 'Conjure Mana Citrine',
    ['isRanked'] = false
  },
  [40] = {
    ['spells'] = {
      [1] = 10054
    },
    ['name'] = 'Conjure Mana Ruby',
    ['isRanked'] = false
  },
  [41] = {
    ['spells'] = {
      [1] = 12472
    },
    ['name'] = 'Cold Snap',
    ['isRanked'] = false
  },
  [42] = {
    ['spells'] = {
      [1] = 11958
    },
    ['name'] = 'Ice Block',
    ['isRanked'] = false
  },
  [43] = {
    ['spells'] = {
      [1] = 11129,
      [2] = 28682
    },
    ['name'] = 'Combustion',
    ['isRanked'] = false
  },
  [44] = {
    ['spells'] = {
      [1] = 12042
    },
    ['name'] = 'Arcane Power',
    ['isRanked'] = false
  },
  [45] = {
    ['spells'] = {
      [1] = 12043
    },
    ['name'] = 'Presence of Mind',
    ['isRanked'] = false
  },
  [46] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1320379,
      [2] = 1324187,
      [3] = 1324188,
      [4] = 1324189
    },
    ['name'] = 'Polymorph',
    ['isRanked'] = false
  },
  [47] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 400625
    },
    ['name'] = 'Heating Up',
    ['isRanked'] = false
  },
  [48] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 12536
    },
    ['name'] = 'Clearcasting',
    ['isRanked'] = false
  },
  [49] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 400589
    },
    ['name'] = 'Missile Barrage',
    ['isRanked'] = false
  },
  [50] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 400573
    },
    ['name'] = 'Arcane Blast',
    ['isRanked'] = false
  },
  [51] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 412538
    },
    ['name'] = 'Ignite',
    ['isRanked'] = false
  },
  [52] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 400670
    },
    ['name'] = 'Fingers of Frost',
    ['isRanked'] = false
  },
  [53] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 12494
    },
    ['name'] = 'Frostbite',
    ['isRanked'] = false
  },
  [54] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 12579
    },
    ['name'] = 'Winter\'s Chill',
    ['isRanked'] = false
  },
  [55] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 22959
    },
    ['name'] = 'Fire Vulnerability',
    ['isRanked'] = false
  },
  [56] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1324401
    },
    ['name'] = 'Counterspell - Silenced',
    ['isRanked'] = false
  },
  [57] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 12355
    },
    ['name'] = 'Impact',
    ['isRanked'] = false
  },
  [58] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 12484
    },
    ['name'] = 'Chilled',
    ['isRanked'] = false
  },
  [59] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 116,
      [2] = 205,
      [3] = 837,
      [4] = 7322,
      [5] = 8406,
      [6] = 8407,
      [7] = 8408,
      [8] = 10179,
      [9] = 10180,
      [10] = 10181,
      [11] = 25304
    },
    ['name'] = 'Frostbolt',
    ['isRanked'] = true
  },
  [60] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 23028
    },
    ['name'] = 'Arcane Brilliance',
    ['isRanked'] = false
  }
}
