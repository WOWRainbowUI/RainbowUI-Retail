local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.15.4.2807
	tag fix
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
elseif E.isCata then E.changelog = [=[
v4.4.0.2807
	tag fix
]=]
else E.changelog = [=[
v11.0.2.2807
	Fixed constant refreshing in Delves (group events fire every second periodically)
	Patch 11.0.5 modifier changes
	tag fix
]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
