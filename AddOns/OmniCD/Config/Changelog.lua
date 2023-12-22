local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.14.4.2772
	Fixed an issue that prevented inspecting offline members when they came back online.

v1.14.4.2771
	Extra Bars can now be used as additional CD bars that attach to each unit's raid frame.

v1.14.4.2768
	bump toc

v1.14.3.2762
	1.14.4 PTR compatibility updates

v1.14.3.2755
	Readiness will reset Deterrence, Feign Death and Trap abilities, instead of all Hunter abilities
]=]
elseif E.isBCC then E.changelog = [=[
v2.5.4.2722
	Fixed sync for cross realm group members
]=]
elseif E.isWOTLKC then E.changelog = [=[
v3.4.3.2772
	Fixed an issue that prevented inspecting offline members when they came back online.

v3.4.3.2771
	Extra Bars can now be used as additional CD bars that attach to each unit's raid frame.
	bump toc

v3.4.2.2768
	Cooldowns will correctly update when non-synced units change specialization

v3.4.2.2762
	bump toc

v3.4.1.2755
	Fixed an issue that prevented CD bars from attaching to the party frames
	Readiness will no longer reset Roar of Sacrifice
	Added arena season 7, 8 equip bonus items
]=]
else E.changelog = [=[
v10.2.0.2772
	Patch 10.2 updates
	Fixed an issue that prevented inspecting offline members when they came back online.

v10.1.7.2771
	Extra Bars can now be used as additional CD bars that attach to each unit's raid frame.

v10.1.7.2770
	Shield Charge will correctly go on CD when used out of melee range.
	Heavy Wingbests/Cloberring Sweep will correctly reduce the CD of Wing Buffet/Tail Swipe.
	Accretion will correctly reduce Upheaval's remaining CD whenever you cast Eruption.

v10.1.7.2769
	Ultimate Sacrifice will correctly go on cooldown when used.
	Ultimate Sacrifice CD fixed to 2min and benefits from Sacrifice of the Just.

v10.1.7.2768
	Patch 10.1.7 spell updates
	PRIEST Angel's Mercy has been redesigned – Now reduces the cooldown of Desperate Prayer by 20 seconds.
	AUGUST 21, 2023 Hotfixes - Dead of Winter now increases the cooldown of Remorseless Winter by 10 seconds (was 25 seconds).
]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
