local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.15.2.2788
	bump toc
	Embeded AceComm w/ ChatThrottleLib.
		> No longer syncs with earlier versions of this addon.

v1.15.0.2775
	Talent inspection will correctly work for group members without OmniCD

]=]
elseif E.isCata then E.changelog = [=[
v4.4.0.2788
	Cataclysm Classic beta (4.4.0.54525)

		> NOTE: Set bonuses are currently inactive in beta.

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
v10.2.7.2788
	Fixed 2pc tier set bonus for Holy Paladin.
	Embeded AceComm w/ ChatThrottleLib.
		> No longer syncs with earlier versions of this addon.

	Updated for Cataclysm Classic

v10.2.7.2787
	bump toc
	Season 4 PvP trinkets added
	Season 4 tier set bonus added

v10.2.6.2786
	bump toc
	10.2.6 Class Updates
		Casting Holy Word: Chastise with Divine Word active now refunds 15 seconds from the cooldown of Holy Word: Chastise.
		Voice of Harmony now causes Holy Nova to reduce the cooldown of Chastise in addition to Holy Fire.
		Lightwell cooldown reduced by 3 seconds when you cast Holy Word: Serenity or Holy Word: Sanctify.
	Talent trees updated

]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
