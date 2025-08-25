--------------------------------------------------------------------------
-- GTFO_Ignore.lua 
--------------------------------------------------------------------------
--[[
GTFO Ignore List
]]--

GTFO.IgnoreSpellCategory["Fatigue"] = {
	spellID = 3271, -- Not really the spell, but a good placeholder
	desc = "Fatigue",
	tooltip = "Alert when entering a fatigue area",
	override = true
}

GTFO.IgnoreSpellCategory["Lava"] = {
	spellID = 16455, -- Not really the spell, but a good placeholder
	desc = "Lava Pools & Campfires",
	tooltip = "Alert when damaged by lava pools and campfires",
	override = true
}

if (GTFO.CataclysmMode or GTFO.RetailMode) then
	GTFO.IgnoreSpellCategory["HagaraWateryEntrenchment"] = {
		-- mobID = 55689; -- Hagara the Stormbinder
		spellID = 110317,
		desc = "Watery Entrenchment (Hagara - Cataclysm)"
	}
end

if (GTFO.RetailMode) then
	GTFO.IgnoreSpellCategory["GarroshDesecrated"] = {
		-- Garrosh Hellscream
		spellID = 144762,
		desc = "Desecrated Axe (Garrosh Phase 1 & 2)",
		tooltip = "Alert from the Desecrated Axe from Garrosh Hellscream (Phase 1 & 2 - MOP)",
		override = true
	}

	GTFO.IgnoreSpellCategory["EyeOfCorruption2"] = {
		-- 8.3 Corruption
		spellID = 315161,
		desc = "Eye of Corruption (8.3 BFA)",
		isDefault = true,
	}

	GTFO.IgnoreSpellCategory["IcyGround"] = {
		-- 10.0 Sennarth
		spellID = 372055,
		desc = "Icy Ground (Sennarth - Dragonflight)",
		tooltip = "Icy Ground (Sennarth - Dragonflight)"
	}
	
	GTFO.IgnoreSpellCategory["SmotheringShadows"] = {
		-- 11.0 Smothering Shadows (darkness aura) from Darkflame Cleft
		spellID = 422806,
		desc = "Smothering Shadows (Darkflame Cleft TWW)",
		tooltip = "Alert from the darkness aura during Darkflame Cleft (TWW)"
	}
end

-- Scanner ignore list
GTFO.IgnoreScan["124255"] = true; -- Monk's Stagger
GTFO.IgnoreScan["124275"] = true; -- Monk's Light Stagger
GTFO.IgnoreScan["34650"] = true; -- Mana Leech
GTFO.IgnoreScan["123051"] = true; -- Mana Leech
GTFO.IgnoreScan["134821"] = true; -- Discharged Energy
GTFO.IgnoreScan["114216"] = true; -- Angelic Bulwark
GTFO.IgnoreScan["6788"] = true; -- Weakened Soul
GTFO.IgnoreScan["136193"] = true; -- Arcing Lightning
GTFO.IgnoreScan["139107"] = true; -- Mind Daggers
GTFO.IgnoreScan["156152"] = true; -- Gushing Wounds
GTFO.IgnoreScan["162510"] = true; -- Tectonic Upheavel
GTFO.IgnoreScan["98021"] = true; -- Spirit Link (Shaman)
GTFO.IgnoreScan["148760"] = true; -- Pheromone Cloud
GTFO.IgnoreScan["175982"] = true; -- Rain of Slag
GTFO.IgnoreScan["158519"] = true; -- Quake
GTFO.IgnoreScan["104330"] = true; -- Demonic Synergy
GTFO.IgnoreScan["1604"] = true; -- Dazed
GTFO.IgnoreScan["187464"] = true; -- Shadow Mend
GTFO.IgnoreScan["186439"] = true; -- Shadow Mend
GTFO.IgnoreScan["210279"] = true; -- Creeping Nightmares
GTFO.IgnoreScan["203121"] = true; -- Mark of Taerer
GTFO.IgnoreScan["203125"] = true; -- Mark of Emeriss
GTFO.IgnoreScan["203102"] = true; -- Mark of Ysondre
GTFO.IgnoreScan["203124"] = true; -- Mark of Lethon
GTFO.IgnoreScan["204766"] = true; -- Energy Surge (Skorpyron)
GTFO.IgnoreScan["218503"] = true; -- Recursive Strikes
GTFO.IgnoreScan["218508"] = true; -- Recursive Strikes
GTFO.IgnoreScan["186416"] = true; -- Torment of Flames
GTFO.IgnoreScan["80354"] = true; -- Time Warp
GTFO.IgnoreScan["258018"] = true; -- Sense of Dread
GTFO.IgnoreScan["294856"] = true; -- Unstable Mixture
GTFO.IgnoreScan["287769"] = true; -- N'Zoth's Awareness
GTFO.IgnoreScan["306583"] = true; -- Leaden Foot
GTFO.IgnoreScan["326788"] = true; -- Chilling Winds
GTFO.IgnoreScan["329961"] = true; -- Lycara's Bargain
GTFO.IgnoreScan["322757"] = true; -- Wrath of Zolramus
GTFO.IgnoreScan["325184"] = true; -- Loose Anima
GTFO.IgnoreScan["334909"] = true; -- Oppressive Atmosphere
GTFO.IgnoreScan["332444"] = true; -- Crumbling Foundation
GTFO.IgnoreScan["335298"] = true; -- Giant Fists
GTFO.IgnoreScan["326469"] = true; -- Torment: Soulforge heat
GTFO.IgnoreScan["347668"] = true; -- Grasp of Death
GTFO.IgnoreScan["358198"] = true; -- Black Heat
GTFO.IgnoreScan["355786"] = true; -- Blackened Armor
GTFO.IgnoreScan["356846"] = true; -- Lingering Flames
GTFO.IgnoreScan["357231"] = true; -- Anguish
GTFO.IgnoreScan["356253"] = true; -- Dreadbugs
GTFO.IgnoreScan["356447"] = true; -- Dreadbugs
GTFO.IgnoreScan["209858"] = true; -- Necrotic Wound
GTFO.IgnoreScan["355951"] = true; -- Unworthy
GTFO.IgnoreScan["366943"] = true; -- Radioactive Core
GTFO.IgnoreScan["368146"] = true; -- Eternity Engine
GTFO.IgnoreScan["362130"] = true; -- Quaking Steps
GTFO.IgnoreScan["361818"] = true; -- Hopebreaker
GTFO.IgnoreScan["364845"] = true; -- Fractured Core
GTFO.IgnoreScan["360287"] = true; -- Anguishing Strike
GTFO.IgnoreScan["360302"] = true; -- Swarm of Decay
GTFO.IgnoreScan["360303"] = true; -- Swarm of Darkness
GTFO.IgnoreScan["361923"] = true; -- Ravenous Hunger
GTFO.IgnoreScan["359778"] = true; -- Ephemera Dust
GTFO.IgnoreScan["294720"] = true; -- Bottled Enimga
GTFO.IgnoreScan["396233"] = true; -- Thundering Presence
GTFO.IgnoreScan["396222"] = true; -- Shattering Presence
GTFO.IgnoreScan["396212"] = true; -- Chilling Presence
GTFO.IgnoreScan["396201"] = true; -- Blistering Presence
GTFO.IgnoreScan["384637"] = true; -- Raging Winds
GTFO.IgnoreScan["388290"] = true; -- Cyclone
GTFO.IgnoreScan["375889"] = true; -- Greatstaff of the Broodkeeper
GTFO.IgnoreScan["381349"] = true; -- Greatstaff of the Broodkeeper
GTFO.IgnoreScan["381250"] = true; -- Electric Lash
GTFO.IgnoreScan["381251"] = true; -- Electric Lash
GTFO.IgnoreScan["382541"] = true; -- Surge
GTFO.IgnoreScan["391282"] = true; -- Crackling Energy
GTFO.IgnoreScan["387333"] = true; -- Storm Surge
GTFO.IgnoreScan["396328"] = true; -- Quaking Pillar
GTFO.IgnoreScan["381931"] = true; -- Mana Spring
GTFO.IgnoreScan["361029"] = true; -- Time Dilation
GTFO.IgnoreScan["363143"] = true; -- Light Dilation
GTFO.IgnoreScan["408370"] = true; -- Infernal Heart 
GTFO.IgnoreScan["411913"] = true; -- Shadowflame Exhaust
GTFO.IgnoreScan["402617"] = true; -- Blazing Heat
GTFO.IgnoreScan["401809"] = true; -- Corrupting Shadow
GTFO.IgnoreScan["405394"] = true; -- Shadowflame Contamination
GTFO.IgnoreScan["407329"] = true; -- Shatter
GTFO.IgnoreScan["413546"] = true; -- Igniting Roar
GTFO.IgnoreScan["403978"] = true; -- Blast Wave
GTFO.IgnoreScan["405618"] = true; -- Ignara's Fury
GTFO.IgnoreScan["403057"] = true; -- Surrender to Corruption
GTFO.IgnoreScan["407048"] = true; -- Surrender to Corruption
GTFO.IgnoreScan["264689"] = true; -- Fatigue
GTFO.IgnoreScan["402053"] = true; -- Seared
GTFO.IgnoreScan["403319"] = true; -- Echoing Howl
GTFO.IgnoreScan["404550"] = true; -- Mana Spring
GTFO.IgnoreScan["382912"] = true; -- Well Honed Instincts
GTFO.IgnoreScan["403912"] = true; -- Accelerating Time
GTFO.IgnoreScan["405671"] = true; -- Accelerating Time
GTFO.IgnoreScan["403910"] = true; -- Decaying Time
GTFO.IgnoreScan["405672"] = true; -- Decaying Time
GTFO.IgnoreScan["420715"] = true; -- Noxious Blossom
GTFO.IgnoreScan["425357"] = true; -- Surging Growth
GTFO.IgnoreScan["421368"] = true; -- Unravel
GTFO.IgnoreScan["423195"] = true; -- Inflorescence
GTFO.IgnoreScan["423670"] = true; -- Continuum
GTFO.IgnoreScan["408469"] = true; -- Call to Suffering
GTFO.IgnoreScan["421674"] = true; -- Burning Vertebrae
GTFO.IgnoreScan["425479"] = true; -- Dream's Blessing
GTFO.IgnoreScan["421407"] = true; -- Searing Ash
GTFO.IgnoreScan["421315"] = true; -- Consuming Flame
GTFO.IgnoreScan["417585"] = true; -- Combusting Presence
GTFO.IgnoreScan["421671"] = true; -- Serpent's Fury
GTFO.IgnoreScan["421674"] = true; -- Burning Vertebrae
GTFO.IgnoreScan["428359"] = true; -- Blistering Heat
GTFO.IgnoreScan["430324"] = true; -- Uprooted Agony
GTFO.IgnoreScan["422026"] = true; -- Tortured Scream
GTFO.IgnoreScan["421986"] = true; -- Tainted Bloom
GTFO.IgnoreScan["430052"] = true; -- Searing Screams
GTFO.IgnoreScan["423705"] = true; -- Burning Scales
GTFO.IgnoreScan["418978"] = true; -- Burning Presence
GTFO.IgnoreScan["420714"] = true; -- Noxious Blossom
GTFO.IgnoreScan["425461"] = true; -- Tainted Heart
GTFO.IgnoreScan["295625"] = true; -- Anger of the Bloodfin
GTFO.IgnoreScan["422750"] = true; -- Shadowflame Rage
GTFO.IgnoreScan["453445"] = true; -- Brilliance
GTFO.IgnoreScan["441197"] = true; -- Righteous Frenzy
GTFO.IgnoreScan["457686"] = true; -- Sureki Zealot's Oath
GTFO.IgnoreScan["434796"] = true; -- Resonant Barrage
GTFO.IgnoreScan["451764"] = true; -- Radiant Flame
GTFO.IgnoreScan["435148"] = true; -- Blazing Strike
GTFO.IgnoreScan["423665"] = true; -- Embrace the Light
GTFO.IgnoreScan["387846"] = true; -- Fel Armor
GTFO.IgnoreScan["458340"] = true; -- Cosmic Simulacrum
GTFO.IgnoreScan["441314"] = true; -- Lacerated Wound
GTFO.IgnoreScan["404551"] = true; -- Mana Spring
GTFO.IgnoreScan["454860"] = true; -- Infectious Wound
GTFO.IgnoreScan["439198"] = true; -- Lingering Venom
GTFO.IgnoreScan["434705"] = true; -- Tenderized
GTFO.IgnoreScan["435136"] = true; -- Venomous Lash
GTFO.IgnoreScan["434776"] = true; -- Carnivorous Contest
GTFO.IgnoreScan["439037"] = true; -- Disembowel
GTFO.IgnoreScan["438012"] = true; -- Hungering Bellows
GTFO.IgnoreScan["445005"] = true; -- Putrid Being
GTFO.IgnoreScan["448060"] = true; -- Hex of Abhorrence
GTFO.IgnoreScan["443305"] = true; -- Crimson Rain 
GTFO.IgnoreScan["443612"] = true; -- Gruesome Disgorge
GTFO.IgnoreScan["444704"] = true; -- Savage Wound
GTFO.IgnoreScan["444702"] = true; -- Savage Wound
GTFO.IgnoreScan["440193"] = true; -- Lingering Erosion
GTFO.IgnoreScan["454860"] = true; -- Infectious Wound
GTFO.IgnoreScan["437839"] = true; -- Nether Rift
GTFO.IgnoreScan["436996"] = true; -- Stalking Shadows
GTFO.IgnoreScan["439861"] = true; -- Dark Sermon
GTFO.IgnoreScan["460600"] = true; -- Entropic Barrage
GTFO.IgnoreScan["461910"] = true; -- Cosmic Ascension
GTFO.IgnoreScan["453609"] = true; -- Liquefy
GTFO.IgnoreScan["471303"] = true; -- Shocking Blast
GTFO.IgnoreScan["459145"] = true; -- Bloodstained Blessing
GTFO.IgnoreScan["465795"] = true; -- Noise pollution
GTFO.IgnoreScan["468120"] = true; -- Resonant Echoes
GTFO.IgnoreScan["474490"] = true; -- Short Circuit
GTFO.IgnoreScan["460388"] = true; -- Backfire
GTFO.IgnoreScan["468147"] = true; -- Exhaust Fumes
GTFO.IgnoreScan["472225"] = true; -- Galvanized Spite
GTFO.IgnoreScan["470032"] = true; -- Colossal Clash
GTFO.IgnoreScan["470034"] = true; -- Colossal Clash
GTFO.IgnoreScan["472222"] = true; -- Blistering Spite
GTFO.IgnoreScan["468665"] = true; -- Elemental Calamity
GTFO.IgnoreScan["469052"] = true; -- Searing Shrapnel
GTFO.IgnoreScan["469043"] = true; -- Searing Shrapnel
GTFO.IgnoreScan["469708"] = true; -- Uncontrolled Destruction
GTFO.IgnoreScan["466752"] = true; -- Venting Heat
GTFO.IgnoreScan["465232"] = true; -- Sonic Ba-Boom
GTFO.IgnoreScan["469620"] = true; -- Creeping Shadow
GTFO.IgnoreScan["420919"] = true; -- Eerie Molds
GTFO.IgnoreScan["443694"] = true; -- Crude Weapons
GTFO.IgnoreScan["425555"] = true; -- Crude Weapons
GTFO.IgnoreScan["424322"] = true; -- Explosive Flame
GTFO.IgnoreScan["469719"] = true; -- Uncontrolled Burn
GTFO.IgnoreScan["460164"] = true; -- Foul Exhaust
GTFO.IgnoreScan["1218343"] = true; -- Toxic Fumes
GTFO.IgnoreScan["200010"] = true; -- Power Leech
GTFO.IgnoreScan["1233110"] = true; -- Purging Lightning
GTFO.IgnoreScan["1223212"] = true; -- Pulsing Darkness
GTFO.IgnoreScan["1226951"] = true; -- Arcane Infusion
GTFO.IgnoreScan["1248319"] = true; -- Inhibiting Touch
GTFO.IgnoreScan["1231469"] = true; -- Arcane Overflow
GTFO.IgnoreScan["1227784"] = true; -- Arcane Outrage
GTFO.IgnoreScan["1227163"] = true; -- Writhing Wave 
GTFO.IgnoreScan["1248435"] = true; -- Arcane Touch
GTFO.IgnoreScan["1226277"] = true; -- Entropic Howl
GTFO.IgnoreScan["1241901"] = true; -- Mass Binding
GTFO.IgnoreScan["1231059"] = true; -- Essence Implosion
GTFO.IgnoreScan["1240763"] = true; -- Spellburn
GTFO.IgnoreScan["1223859"] = true; -- Arcane Expulsion
GTFO.IgnoreScan["1240705"] = true; -- Astral Burn
GTFO.IgnoreScan["1240708"] = true; -- Astral Burn
GTFO.IgnoreScan["1228510"] = true; -- Overwhelming Power
GTFO.IgnoreScan["1228103"] = true; -- Arcane Syphon
GTFO.IgnoreScan["1233301"] = true; -- Dark Singularity
GTFO.IgnoreScan["1225155"] = true; -- Immolation Aura
GTFO.IgnoreScan["1245384"] = true; -- Fel Inferno 
GTFO.IgnoreScan["1221477"] = true; -- Eye Beam
GTFO.IgnoreScan["1221490"] = true; -- Fel-Singed
GTFO.IgnoreScan["1225130"] = true; -- Felblade
GTFO.IgnoreScan["1242304"] = true; -- Expulsed Soul 
GTFO.IgnoreScan["1254762"] = true; -- Frailty
GTFO.IgnoreScan["1225452"] = true; -- Dark Star
GTFO.IgnoreScan["1226363"] = true; -- Twilight Scar
GTFO.IgnoreScan["1228280"] = true; -- King's Hunger
GTFO.IgnoreScan["1234902"] = true; -- Cosmic Maw
GTFO.IgnoreScan["1237775"] = true; -- Cosmic Radiation
GTFO.IgnoreScan["1243702"] = true; -- Antimatter
GTFO.IgnoreScan["1231194"] = true; -- Fission
GTFO.IgnoreScan["1228056"] = true; -- Reap
GTFO.IgnoreScan["1228368"] = true; -- Cosmic Radiation
GTFO.IgnoreScan["1232895"] = true; -- Cosmic Radiation
GTFO.IgnoreScan["1246053"] = true; -- Omega Fueled
GTFO.IgnoreScan["000000"] = true; -- 
GTFO.IgnoreScan["000000"] = true; -- 
GTFO.IgnoreScan["000000"] = true; -- 
GTFO.IgnoreScan["000000"] = true; -- 
GTFO.IgnoreScan["000000"] = true; -- 
