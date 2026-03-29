local _, T = ...

function T.WhatsNewData(vh, uv, li)
	vh("v8.3")
	li("Added <tt>[in:midnight]</tt> extended conditional token.")
	li("Added <tt>[prey]</tt> extended conditional, satisfied while hunting Prey.")
	li("<b>Path of the Seasoned Hero</b> now teleports to Midnight Season 1 Mythic+ dungeons.")
	uv("Updated default rings for Midnight content.")
	vh("v8.2")
	uv("Transmogrification Outfits can now be added to OPie rings.")
	li("Added <tt>[race:haranir]</tt> extended conditional token.")
	li("Conflicted slice bindings are no longer shown on the slice. The conflicting binding is identified in the slice tooltip.")
	uv("[.2] More transmogrification outfits can now be added to OPie rings.")
	vh("v8.1")
	li("[.4] OPie can now display secret ability cooldowns on patch 12.0.1.")
	uv("[.3] Fixed an error that could occur in PvP matches or Mythic+ when using certain insecure macro conditionals on patch 12.0.0.")
	uv("[.2] Fixed an error that occurred when viewing target marker slices with an already-marked target on patch 12.0.0.")
	li("Compatibility update for patch 12.0.0.")
end