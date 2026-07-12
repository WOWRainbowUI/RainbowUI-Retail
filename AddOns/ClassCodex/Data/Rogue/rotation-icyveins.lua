ClassCodexIcyVeinsRotation = ClassCodexIcyVeinsRotation or {}
ClassCodexIcyVeinsRotation["ROGUE"] = {
  ["assassination"] = {
    rotations = {
      { heroTalent = "All", context = "單目標", steps = {
        "Maintain {703}. Use it from {1856} when possible (before every Deathmark).",
        "Maintain {1943} with 5+ Combo Points.",
        "Activate {360194} when available.",
        "Use {385627} on cooldown. Make sure to sync it with Deathmark.",
        "Cast {32645} with 5+ Combo Points.",
        "Cast {8676} to generate Combo Points whenever it is usable.",
        "Cast {1329} to generate Combo Points.",
        "Use {381623} alongside {385627}.",
      } },
      { heroTalent = "All", context = "AoE", steps = {
        "Make sure to use {703} to apply {457052}. Cast it twice to extend the {381632} to its max duration on opener.",
        "Swap your {457052} with {1293340} if you need to swap targets and are still multiple finishers away from a {457058} proc.",
        "Cast {703}, ideally from {1784}, and cast {1943} with 5+ CP.",
        "Maintain {703} and {1943} on all targets by using {1247227} as your AoE builder.",
        "Use {1247227} as your AoE builder to spread bleeds. If all targets have bleeds already, use {51723} instead.",
        "Activate {360194} when available.",
        "Use {385627} (if talented) on cooldown. Make sure to sync it with Deathmark if it is ready.",
        "Use {1856} to re-apply {703}s buffed by {381632} if your initial set of DoTs are close to running out, and the pack is going to live for another ~20+ seconds.",
        "Cast {32645} with 5+ Combo Points.",
        "Cast {32645} with 5+ Combo Points. Cast it with 7 CP when {457058} is active.",
        "Use {381623} alongside {385627}.",
        "You can use {5938} if at 6 CP and {457058} is available.",
      } },
    },
  },
  ["outlaw"] = {
    rotations = {
      { heroTalent = "All", context = "單目標", steps = {
        "Your rotational priority is virtually the same in single-target and AoE. The only difference is the usage of {13877}. You will want to use BF on cooldown whenever there is a second target in cleave range, but try to use it at low Combo Points to gain the full benefit of {381878}.",
        "Use {315508} on cooldown unless you are already in Stage 2 or higher.",
        "Use {381989} when you are in Stage 3. If your next {315508} is unlikely to be used alongside {256170}, you can KIR at Stage 2 as well.",
        "Use {13750} on cooldown, at low Combo Points.",
        "Use {271877} on cooldown as if it were a regular builder.",
        "Cast {315341} on cooldown with 6+ CP.",
        "Use {1277933} to reset the cooldown of your AR, BtE, and Blade Rush.",
        "Use {51690} on cooldown, at 6+ Combo Points. Try to avoid using it while {470347} is active. You risk overcapping Energy if you do, and it is recommended to cancel KS whenever you cap Energy during its duration.",
        "Cast {2098} as your main finisher with 5+ CP if no other finishers are available to be used.",
        "Cast {2098} as your main finisher with 6+ CP if no other finishers are available to be used.",
        "Cast {185763} if you have 6 stacks of {279876}. If you have 3 stacks, use it at 1-3 CPs only.",
        "Cast {1752} to generate Combo Points.",
      } },
    },
  },
  ["subtlety"] = {
    rotations = {
      { heroTalent = "All", context = "Rotation", steps = {
        "Cast {185313} when you have 6 or more combo points and {280719} is ready or {121471} is active.",
        "Cast {185313} when you have 2 or fewer combo points and {280719} is ready or {121471} is active.",
        "Cast {121471} during {185313}.",
        "Cast {280719} during {185313} with 6 or more combo points.",
        "Cast {441423} with 6 or more combo points.",
        "Cast {196819} with 6 or more combo points.",
        "Cast {185438} whenever you can, otherwise cast {53} to build combo points.",
        "Cast {185438} whenever you can, otherwise cast {426591} or {53} to build combo points.",
      } },
    },
  },
}
