local _, T = ...

function T.WhatsNewData(vh, uv, li)
	vh("v7.11.2")
	uv([[Nested rings used as on-open actions now respect rotation-related <b>Display as</b> settings.]])
	uv([[Quick action repeat triggers are now available for rings opened via a jump slice.]])
	vh("v7.11.1")
	uv([[Added <tt>[in:legacy]</tt> extended conditional token, satisfied when legacy loot rules are active.]])
	li([[Added an in-game <b>What's New</b> list, accessible from the new <b>Home</b> tab in the <b>Options</b> window. (Hi!)]])
	vh("Ånd 7.5 (2025-10-31)")
	li([[Loot toasts are now dismissed by default when you open an OPie ring. You can control this behavior using the <b>Hide toasts on ring open</b> checkbox in the Behavior section of <tt>/opie</tt> options.]])
	li([[Feedback for |cff71d5ffSingle-Button Assitant|r macros now reflects the spell the assistant will cast.]])
	li([[|cff71d5ffPath of the Seasoned Hero|r can now also teleport to Legion Remix dungeons.]])
	uv([[You can now use <tt>[pet:ferocity/cunning/tenacity]</tt> on Modern and Classic Mists to check the specialization of your Hunter pet. If you have multiple summonable pets of the same species, this relies on unique pet names to identify your active pet.]])
	vh("Ånd 7.3 (2025-09-24)")
	li([[Added a |cff71d5ffPath of the Seasoned Hero|r slice to the built-in <b>Specializations and Travel</b> ring. You can use this "ability" to teleport to a mythic dungeon or raid for which you have learned the relevant Path ability; the destination updates dynamically based on your own keystone and the designated activity of the premade group you have created or joined.]])
end