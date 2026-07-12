ClassCodexIcyVeinsRotation = ClassCodexIcyVeinsRotation or {}
ClassCodexIcyVeinsRotation["MAGE"] = {
  ["arcane"] = {
    rotations = {
      { heroTalent = "All", context = "單目標", steps = {
        "Cast {44425} when {451038} is active.",
        "Spend any {79684} stacks on {5143} when Arcane Surge is about to end, so you have no Clearcasting stacks left when {451038} procs.",
        "Cast {153626} when you have {263725} and your previous spell was {44425}.",
        "Use {205025} for when you need to move and need to cast {30451}",
        "Cast {44425} when you have 4 {36032} stacks and 20 stacks of {384452}.",
        "Cast {44425} if you have 4 {36032} stacks, {79684}, at least 5 {384452} stacks, and {1244329}.",
        "Cast {44425} when you have 4 {36032} stacks and 25 {384452} stacks.",
        "Cast {5143} whenever you have {79684} and less than 3 {36032} stacks.",
        "Cast {5143} whenever you have 2 or more {79684} stacks. - Click for advanced usage tips Only cast Arcane Missiles when you have fewer than 14 {384452} stacks",
        "Only cast Arcane Missiles when you have fewer than 6 {384452} stacks if you also have {1244329}",
        "Cast {153626} when you have 0-2 {36032} stacks.",
        "Cast {30451} as your filler.",
        "Cast {12051} when out of mana and you are not currently during {321507} or {365350}.",
        "Cast {44425} if you do not have enough mana for {30451}.",
      } },
      { heroTalent = "All", context = "AoE", steps = {
        "On 4+ targets, use either {1241462} or {30451} as your filler: Use {1241462} as your filler instead of {30451} for more AoE DPS but lower priority-target DPS.",
        "Use {30451} as your filler to focus on maximizing priority-target DPS but lower overall DPS.",
        "On 4+ targets, cast {153626} whenever you have {79684} and less than 14 {384452} stacks.",
        "On 3+ targets, in addition to the single-target {44425} conditions, also cast it if you have 4 {36032} stacks, less than 18 {384452} stacks, and either a {79684} proc or an {153626} ready. Basically, the goal here is to cast Arcane Barrages whenever you have a good way to get Arcane Charges back, but not so high Arcane Salvo stacks that it is better to wait until you have maxed stacks.",
        "On 3+ targets, in addition to the single-target {44425} conditions, also cast it if you have 4 {36032} stacks, less than 10 {384452} stacks, and either a {79684} proc or an {153626} ready. Basically, the goal here is to cast Arcane Barrages whenever you have a good way to get Arcane Charges back, but not so high Arcane Salvo stacks that it is better to wait until you have maxed stacks.",
      } },
    },
  },
  ["fire"] = {
    rotations = {
      { heroTalent = "All", context = "AoE", steps = {
        "You should stick to using {11366} over {2120} at all target counts if you want to maximize your damage to a specific high priority target.",
        "When the target is above 90% health with {205026} specced: Never use {2120}",
        "Both during and outside of {190319}: 4 or more targets",
        "Both during and outside of {190319}: 4 or more targets",
        "Only replace {11366}, never replace a {133} cast with {2120}!",
        "Only replace {11366}, never replace a {431044} cast with {2120}!",
      } },
    },
  },
  ["frost"] = {
    rotations = {
      { heroTalent = "All", context = "AoE", steps = {
        "Pre-cast {431044} at 2 seconds on the countdown.",
        "Cast {205021}.",
      } },
      { heroTalent = "All", context = "單目標", steps = {
        "Cast {44614} if you have {190447}.",
        "Cast {44614} if {1247729} is not already active and you have {190447}.",
        "Cast {84714}.",
        "Cast {1247777}.",
        "Cast {199786} when available.",
        "Cast {30455} at 10 or more stacks of Freezing, or if {112965} is active.",
        "Cast {44614} if you have a charge available but no {190447}.",
        "Cast {205021}.",
        "Cast {431044}.",
      } },
    },
  },
}
