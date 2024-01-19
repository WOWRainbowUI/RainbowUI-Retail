local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.15.0.2775
	Talent inspection will correctly work for group members without OmniCD

]=]
elseif E.isBCC then E.changelog = [=[
v2.5.4.2722
	Fixed sync for cross realm group members

]=]
elseif E.isWOTLKC then E.changelog = [=[
v3.4.3.2773
	Added season 8 Wrathful Gladiator's set bonuses
	Fixed incorrect sorting when a unit dies or resurrects on ver.2772
	Added option to change icon texture for 'Trinket, Main Hand, Consumables' spell type.

]=]
else E.changelog = [=[
v10.2.5.2780
	Missing talent abilities after 10.2.5 will correctly show
	Addon will no longer sync with older versions

v10.2.5.2777
	Fixed Cycle of Binding CDR when auras are refreshed.
	Fixed Illuminated Sigils not adding a charge to Elysian Decree.

v10.2.5.2776
	Patch 10.2.5 - shared cd for healer pvp trinket updated
	Added Sundering (Enhance Shaman, talent).
	Added highlighting for key Summon abilities (e.g. Gargoyle, Demonic Tyrant, Infernal, Darkglare).
	Berserk (Druid, Feral) spell-type fixed from CC to Offensive. This also fixes highlighting.
	Cycle of Binding (Vengeance DH, talent) fixed: Elysian Decree will correctly reduce other Sigils' remaining CD.
]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
