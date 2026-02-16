local _, T = ...

function T.WhatsNewData(vh, uv, li)
	vh("v8.1")
	li("[.4] OPie can now display secret ability cooldowns on patch 12.0.1.")
	uv("[.3] Fixed an error that could occur in PvP matches or Mythic+ when using certain insecure macro conditionals on patch 12.0.0.")
	uv("[.2] Fixed an error that occurred when viewing target marker slices with an already-marked target on patch 12.0.0.")
	li("Compatibility update for patch 12.0.0.")
	li("OPie does not currently show ability cooldowns while in combat on patch 12.0.0.")
	vh("v7.11")
	uv([[Nested rings used as on-open actions now respect rotation-related <b>Display as</b> settings.]])
	uv([[Quick action repeat triggers are now available for rings opened via a jump slice.]])
	uv([[Added <tt>[in:legacy]</tt> extended conditional token, satisfied when legacy loot rules are active.]])
	li([[Added an in-game <b>What's New</b> list, accessible from the new <b>Home</b> tab in the <b>Options</b> window.]])
end