local E = select(2,	...):unpack()

local covenant_db = {
	["DEATHKNIGHT"] = {
		{ spellID = 315443,	duration = 120,	type = "covenant",	spec = 321078	},
		{ spellID = 324128,	duration = {[250]=15,default=30},	type = "covenant",	spec = 321077,	parent = 43265,	talent = 152280	},
		{ spellID = 312202,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 311648,	duration = 60,	type = "covenant",	spec = 321079	},
	},
	["DEMONHUNTER"] = {
		{ spellID = 306830,	duration = 60,	type = "covenant",	spec = 321076,	talent = 390163	},
		{ spellID = 329554,	duration = 120,	type = "covenant",	spec = 321078	},
		{ spellID = 317009,	duration = 45,	type = "covenant",	spec = 321079	},
		{ spellID = 323639,	duration = 90,	type = "covenant",	spec = 321077,	talent = 370965	},
	},
	["DRUID"] = {
		{ spellID = 325727,	duration = 25,	type = "covenant",	spec = 321078,	talent = 391888	},
		{ spellID = 323764,	duration = 120,	type = "covenant",	spec = 321077,	talent = 391528	},
		{ spellID = 338142,	duration = 60,	type = "covenant",	spec = 321076	},
		--[[ Merged
		{ spellID = 338035,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 338018,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 326462,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 326446,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 326647,	duration = 60,	type = "covenant",	spec = 321076	},

		{ spellID = 326434,	duration = 0,	type = "covenant",	spec = 321076	},
		{ spellID = 327022,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 327037,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 327071,	duration = 60,	type = "covenant",	spec = 321076	},
		]]
		{ spellID = 323546,	duration = 180,	type = "covenant",	spec = 321079	},
	},
	["HUNTER"] = {
		{ spellID = 325028,	duration = 45,	type = "covenant",	spec = 321078	},
		{ spellID = 324149,	duration = 30,	type = "covenant",	spec = 321079	},
		{ spellID = 308491,	duration = 60,	type = "covenant",	spec = 321076	},
		{ spellID = 328231,	duration = 120,	type = "covenant",	spec = 321077	},
	},
	["MAGE"] = {
		{ spellID = 324220,	duration = 180,	type = "covenant",	spec = 321078	},
		{ spellID = 314793,	duration = 90,	type = "covenant",	spec = 321079	},
		{ spellID = 307443,	duration = 30,	type = "covenant",	spec = 321076	},
		{ spellID = 314791,	duration = 60,	type = "covenant",	spec = 321077,	talent = 382440	},
	},
	["MONK"] = {
		{ spellID = 325216,	duration = 60,	type = "covenant",	spec = 321078	},
		{ spellID = 327104,	duration = 30,	type = "covenant",	spec = 321077,	talent = 388193	},
		{ spellID = 326860,	duration = 180,	type = "covenant",	spec = 321079	},
		{ spellID = 310454,	duration = 120,	type = "covenant",	spec = 321076,	talent = 387184	},
	},
	["PALADIN"] = {
		{ spellID = 316958,	duration = 240,	type = "covenant",	spec = 321079	},
		{ spellID = 328620,	duration = 45,	type = "covenant",	spec = 321077,	talent = 388007	},
		--[[ Merged
		{ spellID = 328622,	duration = 45,	type = "covenant",	spec = 321077	},
		{ spellID = 328282,	duration = 45,	type = "covenant",	spec = 321077	},
		{ spellID = 328281,	duration = 45,	type = "covenant",	spec = 321077	},
		]]
		{ spellID = 304971,	duration = 60,	type = "covenant",	spec = 321076,	talent = 375576	},
		{ spellID = 328204,	duration = 30,	type = "covenant",	spec = 321078	},
	},
	["PRIEST"] = {
		{ spellID = 325013,	duration = 180,	type = "covenant",	spec = 321076	},
		{ spellID = 327661,	duration = 90,	type = "covenant",	spec = 321077	},
		{ spellID = 323673,	duration = 45,	type = "covenant",	spec = 321079,	talent = 375901	},
		{ spellID = 324724,	duration = 60,	type = "covenant",	spec = 321078	},
	},
	["ROGUE"] = {
		{ spellID = 323547,	duration = 45,	type = "covenant",	spec = 321076	},
		{ spellID = 323654,	duration = 90,	type = "covenant",	spec = 321079,	talent = 384631	},
		{ spellID = 328305,	duration = 90,	type = "covenant",	spec = 321077	},
		{ spellID = 328547,	duration = 30,	type = "covenant",	spec = 321078,	charges = 3	},
	},
	["SHAMAN"] = {
		{ spellID = 320674,	duration = 90,	type = "covenant",	spec = 321079	},
		{ spellID = 328923,	duration = 120,	type = "covenant",	spec = 321077	},
		{ spellID = 326059,	duration = 45,	type = "covenant",	spec = 321078,	talent = 375982	},
		{ spellID = 324386,	duration = 60,	type = "covenant",	spec = 321076	},
	},
	["WARLOCK"] = {
		{ spellID = 325289,	duration = 45,	type = "covenant",	spec = 321078,	},
		{ spellID = 321792,	duration = 60,	type = "covenant",	spec = 321079,	},
		{ spellID = 312321,	duration = 40,	type = "covenant",	spec = 321076,	},
		{ spellID = 325640,	duration = 60,	type = "covenant",	spec = 321077,	talent = 386997	},
	},
	["WARRIOR"] = {
		{ spellID = 325886,	duration = 90,	type = "covenant",	spec = 321077	},
		{ spellID = 317483,	duration = {[72]=6,default=1},	type = "covenant",	spec = 321079,	parent = 5308	},
		{ spellID = 324143,	duration = 120,	type = "covenant",	spec = 321078	},
		{ spellID = 307865,	duration = 60,	type = "covenant",	spec = 321076,	talent = 376079	},
	},
	["EVOKER"] = {
		{ spellID = 387168,	duration = 120,	type = "covenant",	spec = {321078,321079,321076,321077}	},
	},
	["COVENANT"] = {
		{ spellID = 300728,	duration = 60,	type = "covenant",	spec = 321079	},
		{ spellID = 324631,	duration = 120,	type = "covenant",	spec = 321078,	buff = 324867	},
		{ spellID = 323436,	duration = 180,	type = "covenant",	spec = 321076	},
		{ spellID = 310143,	duration = 90,	type = "covenant",	spec = 321077	},
		{ spellID = 324739,	duration = 300,	type = "covenant",	spec = 321076	},
		{ spellID = 319217,	duration = 600,	type = "covenant",	spec = 319217,	buff = 320224	},
	},
}

for class, t in pairs(covenant_db) do
	local c = E.spell_db[class]
	if c then
		for i = 1, #t do
			c[#c+1] = t[i]
		end
	else
		E.spell_db[class] = t
	end
end
