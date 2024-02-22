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
v10.2.5.2784
	Dark Arbiter will correctly replace Summon Gargoyle.
	Searing Glare cd fix.
	Purification id fix.
	nil err fix (on entering instance w/ Weyrnstone buff).

]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
