ClassCodexIcyVeinsRotation = ClassCodexIcyVeinsRotation or {}
ClassCodexIcyVeinsRotation["DEATHKNIGHT"] = {
  ["blood"] = {
    rotations = {
      { heroTalent = "All", context = "Rotation", steps = {
        "If your cooldown plan still necessitates more than you currently have, evaluate whether you can allocate a group external cooldown to it (something like {6940} from a paladin). If you cannot, or if things hit too frequently or too hard for your current kit, you can consider a defensive trinket to fill a gap in you cooldown plan, or an external from a party member. Don't forget {51052} - most Blood Death Knights tend to forget that it is technically a 15% damage reduction effect against magic damage for you, not just for your group!",
      } },
    },
  },
  ["frost"] = {
    rotations = {
      { heroTalent = "All", context = "單目標", steps = {
        "Use {49020} if you have a proc of {51128}",
        "Use {49143} if you have 5 stacks of {51714}",
        "Use {49143}/ {455993} if you have 5 stacks of {51714}",
        "Use {49184} if you have a proc of {59057}",
        "Use {49143}",
        "Use {47568} to generate a charge of {51128} and 40 Runic Power",
        "Use a no-KM {49020}",
      } },
      { heroTalent = "All", context = "AoE", steps = {
        "{47568}",
        "{207230}",
        "{49020}",
        "{439843}",
        "{196770}",
        "{1249658} + {51271} + Potion + Trinket + {46585}",
        "{51271} + Potion + Trinket + {46585}",
        "{279302}",
        "{49020}",
        "{207230}",
        "{47568}",
        "{207230}",
        "{49020}",
      } },
    },
  },
  ["unholy"] = {
    rotations = {
      { heroTalent = "All", context = "單目標", steps = {
        "Use {77575} to maintain your plagues on the target.",
        "Use {455397} if its buff has fallen off.",
        "Use {343294} if the enemy is below 35% health and your {63560} buff is active, or you have triggered the {377514} effect from {63560}.",
        "Use {47541} when you have a {49530} proc or {1242158} is active.",
        "Use {1247378} if {63560} is active.",
        "Use {1247378} if the target is above 35% health and your {63560} buff is active. If your target is below 35%, use {343294} to trigger your {1247378} instead.",
        "Use {85948} if you have less than 3 stacks of {1254252}.",
        "Use {55090} if you have at least 1 stack of {1254252}.",
        "Use {47541}.",
      } },
      { heroTalent = "All", context = "AoE", steps = {
        "Use {77575}.",
        "Use 2x {85948}.",
        "Use {42650} + {63560} + Trinket + Racial + Potion",
        "Use {343294}.",
        "Use {1247378}",
        "Use {1247378}.",
      } },
    },
  },
}
