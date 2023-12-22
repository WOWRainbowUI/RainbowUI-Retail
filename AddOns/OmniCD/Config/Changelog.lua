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
v10.2.0.2775
	Berserk (Druid, Feral) spell-type fixed to 'Offensive'. This also fixes highlighting.

v10.2.0.2774
	Added option to force disable talent-abilities by spec/zone. (e.g. disable Avenging Wrath for Prot/Ret in raids)
	Updated Thief's Bargain CDR to 20% (December 5, 2023).
	Updated Time Stop, Chrono Loop's CD to 45 sec (November 14, 2023).
	Added trinkets: Fyrakk's Tainted Rageheart, Prophetic Stonescales.
	All healing potions have been merged to 'Refreshing Healing Potion' and it's icon will change to whichever potion was used last.
	Fixed Withering Healing Potion icons.
	Fixed Arcane Surge not highlighting.
	Unsynced unit CDR fixes:
	Fixed Tirion's Devotion for Holy Paladins.
	Fixed Shining Righteousness counting towards Holy Power spent.
	Fixed Shield of Righteousness for Holy Paladins not counting towards Holy Power spent.

v10.2.0.2773
	Fixed incorrect sorting when a unit dies or resurrects on ver.2772
	Added Dreamwalker's Healing Potion, Potion of Withering Dream, Potion of Withering Vitality (merged).
	Added option to change icon texture for 'Trinket, Main Hand, Consumables' spell type.
	Cell support update (test func removed)

]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
