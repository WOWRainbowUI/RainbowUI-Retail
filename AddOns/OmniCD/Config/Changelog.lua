local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.15.2.2790
	critical bug fix

v1.15.2.2788
	bump toc
	Embeded AceComm w/ ChatThrottleLib.
		> No longer syncs with earlier versions of this addon.

v1.15.0.2775
	Talent inspection will correctly work for group members without OmniCD

]=]
elseif E.isCata then E.changelog = [=[
v4.4.0.2790
	critical bug fix

v4.4.0.2788
	Cataclysm Classic beta (4.4.0.54525)

		> NOTE: Set bonuses are currently inactive in beta.

]=]
elseif E.isBCC then E.changelog = [=[
v2.5.4.2722
	Fixed sync for cross realm group members

]=]
elseif E.isWOTLKC then E.changelog = [=[
v3.4.3.2790
	critical bug fix

v3.4.3.2773
	Added season 8 Wrathful Gladiator's set bonuses
	Fixed incorrect sorting when a unit dies or resurrects on ver.2772
	Added option to change icon texture for 'Trinket, Main Hand, Consumables' spell type.

]=]
else E.changelog = [=[
v10.2.7.2790
	critical bug fix

v10.2.7.2789
	MAY 7, 2024 Hotfixes
		Sigil of Silence cooldown increased to 90 seconds (was 60 seconds).
		Cycle of Binding now reduces Sigil cooldowns by 2 seconds per trigger (was 3 seconds).
		Disrupting Shout’s cooldown reduced to 75 seconds (was 90 seconds).
	Time of Need (Evoker, Preservation) moved to External Defensives.
]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
