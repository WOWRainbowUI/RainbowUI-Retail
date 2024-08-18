local MAJOR_VERSION, MINOR_VERSION = "LibRealDispel-1.0", 9
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type = _G.type
local next = _G.next
local select = _G.select
local pairs = _G.pairs
local wipe = _G.table.wipe
local IsSpellKnown = _G.IsSpellKnown
local IsSpellKnownOrOverridesKnown = _G.IsSpellKnownOrOverridesKnown
local UnitCanAttack = _G.UnitCanAttack
local UnitCanAssist = _G.UnitCanAssist
if not IsSpellKnownOrOverridesKnown then IsSpellKnownOrOverridesKnown = IsSpellKnown end

local scanDispel
local class = select(2, UnitClass("player"))

lib.Callbacks = lib.Callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.blankfunc = lib.blankfunc or function() return nil end
lib.help = lib.help or {}
lib.enrageSpells = lib.enrageSpells or {}
wipe(lib.enrageSpells)
lib.enrageSpells[134] = true
lib.enrageSpells[256] = true
lib.enrageSpells[772] = true
lib.enrageSpells[4146] = true
lib.enrageSpells[8599] = true
lib.enrageSpells[12880] = true
lib.enrageSpells[14201] = true
lib.enrageSpells[14202] = true
lib.enrageSpells[14203] = true
lib.enrageSpells[14204] = true
lib.enrageSpells[15061] = true
lib.enrageSpells[15716] = true
lib.enrageSpells[18501] = true
lib.enrageSpells[19451] = true
lib.enrageSpells[19812] = true
lib.enrageSpells[22428] = true
lib.enrageSpells[23128] = true
lib.enrageSpells[23257] = true
lib.enrageSpells[23342] = true
lib.enrageSpells[24689] = true
lib.enrageSpells[25503] = true
lib.enrageSpells[26041] = true
lib.enrageSpells[26051] = true
lib.enrageSpells[28371] = true
lib.enrageSpells[29131] = true
lib.enrageSpells[29340] = true
lib.enrageSpells[30485] = true
lib.enrageSpells[31540] = true
lib.enrageSpells[31915] = true
lib.enrageSpells[32714] = true
lib.enrageSpells[33958] = true
lib.enrageSpells[34392] = true
lib.enrageSpells[34670] = true
lib.enrageSpells[37605] = true
lib.enrageSpells[37648] = true
lib.enrageSpells[37975] = true
lib.enrageSpells[38046] = true
lib.enrageSpells[38166] = true
lib.enrageSpells[38664] = true
lib.enrageSpells[39031] = true
lib.enrageSpells[39575] = true
lib.enrageSpells[40076] = true
lib.enrageSpells[40601] = true
lib.enrageSpells[41254] = true
lib.enrageSpells[41364] = true
lib.enrageSpells[41447] = true
lib.enrageSpells[42705] = true
lib.enrageSpells[42745] = true
lib.enrageSpells[43139] = true
lib.enrageSpells[43292] = true
lib.enrageSpells[43664] = true
lib.enrageSpells[47399] = true
lib.enrageSpells[48138] = true
lib.enrageSpells[48142] = true
lib.enrageSpells[48193] = true
lib.enrageSpells[48391] = true
lib.enrageSpells[48702] = true
lib.enrageSpells[49029] = true
lib.enrageSpells[50420] = true
lib.enrageSpells[50636] = true
lib.enrageSpells[51170] = true
lib.enrageSpells[51513] = true
lib.enrageSpells[51662] = true
lib.enrageSpells[52071] = true
lib.enrageSpells[52262] = true
lib.enrageSpells[52309] = true
lib.enrageSpells[52461] = true
lib.enrageSpells[52470] = true
lib.enrageSpells[52537] = true
lib.enrageSpells[53361] = true
lib.enrageSpells[54356] = true
lib.enrageSpells[54427] = true
lib.enrageSpells[54475] = true
lib.enrageSpells[54508] = true
lib.enrageSpells[54781] = true
lib.enrageSpells[55285] = true
lib.enrageSpells[55462] = true
lib.enrageSpells[56646] = true
lib.enrageSpells[56729] = true
lib.enrageSpells[56769] = true
lib.enrageSpells[57514] = true
lib.enrageSpells[57516] = true
lib.enrageSpells[57518] = true
lib.enrageSpells[57519] = true
lib.enrageSpells[57520] = true
lib.enrageSpells[57521] = true
lib.enrageSpells[57522] = true
lib.enrageSpells[57733] = true
lib.enrageSpells[58942] = true
lib.enrageSpells[59465] = true
lib.enrageSpells[59694] = true
lib.enrageSpells[59697] = true
lib.enrageSpells[59707] = true
lib.enrageSpells[59828] = true
lib.enrageSpells[60075] = true
lib.enrageSpells[60177] = true
lib.enrageSpells[60430] = true
lib.enrageSpells[61369] = true
lib.enrageSpells[62071] = true
lib.enrageSpells[63147] = true
lib.enrageSpells[63227] = true
lib.enrageSpells[63848] = true
lib.enrageSpells[66092] = true
lib.enrageSpells[66759] = true
lib.enrageSpells[67233] = true
lib.enrageSpells[67657] = true
lib.enrageSpells[67658] = true
lib.enrageSpells[67659] = true
lib.enrageSpells[68541] = true
lib.enrageSpells[69052] = true
lib.enrageSpells[70371] = true
lib.enrageSpells[72143] = true
lib.enrageSpells[72146] = true
lib.enrageSpells[72147] = true
lib.enrageSpells[72148] = true
lib.enrageSpells[72203] = true
lib.enrageSpells[75998] = true
lib.enrageSpells[76100] = true
lib.enrageSpells[76487] = true
lib.enrageSpells[76691] = true
lib.enrageSpells[76816] = true
lib.enrageSpells[76862] = true
lib.enrageSpells[77238] = true
lib.enrageSpells[78722] = true
lib.enrageSpells[78943] = true
lib.enrageSpells[79420] = true
lib.enrageSpells[80084] = true
lib.enrageSpells[80158] = true
lib.enrageSpells[80467] = true
lib.enrageSpells[81706] = true
lib.enrageSpells[81772] = true
lib.enrageSpells[82033] = true
lib.enrageSpells[82759] = true
lib.enrageSpells[86736] = true
lib.enrageSpells[90045] = true
lib.enrageSpells[91668] = true

--lib.enrageSpells[264064] = true	-- 8.0
--lib.enrageSpells[274780] = true	-- 8.0
--lib.enrageSpells[311086] = true	-- 8.0
--lib.enrageSpells[313675] = true	-- 8.0
--lib.enrageSpells[314466] = true	-- 8.0

--lib.enrageSpells[314466] = true	-- 8.0
lib.enrageSpells[228318] = true	-- 9.0
lib.enrageSpells[257260] = true	-- 8.0	Mythic Dungeon
lib.enrageSpells[324085] = true	-- 9.0	              -           þ 
lib.enrageSpells[324737] = true	-- 9.0	Ƽ        ̵     Ȱ  -  Ȱ  帷   ȣ  
lib.enrageSpells[333227] = true	-- 9.0	     -  ǻ Ƴ   屺
lib.enrageSpells[334967] = true	-- 9.0	     -     Į   θ 
lib.enrageSpells[326450] = true	-- 9.0	            - Ÿ       ɰ    û 
lib.enrageSpells[321220] = true	-- 9.0	 ͺ   ɿ  -            
lib.enrageSpells[334470] = true	-- 9.0	 ͺ   ɿ  -                
lib.enrageSpells[320703] = true	-- 9.0	           ,   õ        -             


if class == "WARRIOR" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil--IsSpellKnown(58375) and true or nil
		wipe(lib.help)
	end
elseif class == "ROGUE" then
	function scanDispel()
		lib.tranquilize = nil--IsSpellKnown(5938) and true or nil
		lib.harm = nil
		wipe(lib.help)
	end
elseif class == "PRIEST" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = IsSpellKnown(528) and true or nil
		wipe(lib.help)
		lib.help.Magic = IsSpellKnown(527) and true or nil
		lib.help.Disease = lib.help.Magic
	end
elseif class == "MAGE" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = IsSpellKnownOrOverridesKnown(30449) and true or nil
		wipe(lib.help)
		lib.help.Curse = IsSpellKnown(475) and true or nil
	end
elseif class == "WARLOCK" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = IsSpellKnown(19505, true) and true or nil
		wipe(lib.help)
		lib.help.Magic = IsSpellKnown(89808, true) and true or nil
	end
elseif class == "HUNTER" then
	function scanDispel()
		lib.tranquilize = IsSpellKnown(19801) and true or nil
		lib.harm = lib.tranquilize
		wipe(lib.help)
	end
elseif class == "DRUID" then
	function scanDispel()
		lib.tranquilize = IsSpellKnown(2908) and true or nil
		lib.harm = nil
		wipe(lib.help)
		lib.help.Curse = (IsSpellKnown(2782) or IsSpellKnown(88423)) and true or nil
		lib.help.Poison = lib.help.Curse
		lib.help.Magic = IsSpellKnown(88423) and true or nil
	end
elseif class == "SHAMAN" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = (IsPlayerSpell(370) or IsPlayerSpell(378773)) and true or nil
		wipe(lib.help)
		lib.help.Poison = IsPlayerSpell(383013) and true or nil
		lib.help.Curse = IsPlayerSpell(383016) and true or nil
		lib.help.Magic = (IsPlayerSpell(77130) or IsPlayerSpell(383016)) and true or nil
	end
elseif class == "PALADIN" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
		lib.help.Poison = (IsSpellKnown(213644) or IsSpellKnown(4987)) and true or nil
		lib.help.Disease = lib.help.Poison
		lib.help.Magic = IsSpellKnown(4987) and true or nil
	end
elseif class == "MONK" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
		lib.help.Poison = (IsSpellKnown(218164) or IsSpellKnown(115450)) and true or nil
		lib.help.Disease = lib.help.Poison
		lib.help.Magic = (IsSpellKnown(115450) or IsSpellKnown(115310) or IsSpellKnown(117907)) and true or nil	-- 115450 bug
	end
elseif class == "DEMONHUNTER" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
	end
elseif class == "EVOKER" then
	function scanDispel()
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
		lib.help.Poison = (IsSpellKnownOrOverridesKnown(365585) or IsSpellKnownOrOverridesKnown(360823) or IsSpellKnownOrOverridesKnown(374251)) and true or nil
		lib.help.Disease = IsSpellKnownOrOverridesKnown(374251) and true or nil
		lib.help.Curse = IsSpellKnownOrOverridesKnown(374251) and true or nil
		lib.help.Magic = IsSpellKnownOrOverridesKnown(360823) and true or nil
	end
else
	lib.Dispel = lib.blankfunc
	lib.DispelHelp = lib.blankfunc
	lib.DispelHarm = lib.blankfunc
	lib.CheckHarmDispel = lib.blankfunc
	lib.CheckHelpDispel = lib.blankfunc
	lib.IsDispelable = lib.blankfunc
	if lib.frame then
		lib.frame:UnregisterAllEvents()
		lib.frame:SetScript("OnEvent", nil)
	end
	if lib.tranquilize or lib.harm or next(lib.help) then
		lib.tranquilize = nil
		lib.harm = nil
		wipe(lib.help)
		lib.Callbacks:Fire("Update")
	end
	return
end

local name, auraType, auraID, _

function lib:CheckHarmDispel(aura, spell)
	return (lib.harm and aura == "Magic") or (lib.tranquilize and lib.enrageSpells[spell])
end

function lib:CheckHelpDispel(aura)
	return lib.help[aura]
end

function lib:IsDispelable(unit, index)
	local aura, auraType, auraID
	if UnitCanAttack("player", unit) then
		-- local auraType, _, _, _, _, _, auraID = select(4, UnitBuff(unit, index))
		aura = C_UnitAuras.GetBuffDataByIndex(unit, index)
		if aura then
			auraType = aura.dispelName
			auraID = aura.spellId
		end
		return lib:CheckHarmDispel(auraType, auraID)
	elseif UnitCanAssist("player", unit) then
		aura = C_UnitAuras.GetDebuffDataByIndex(unit, index)
		if aura then
			auraType = aura.dispelName
		end
		return lib:CheckHelpDispel(auraType or nil)
	end
	return nil
end

function lib:DispelHelp(unit, usablefunc)
	if next(lib.help) then
		local aura, name, auraType, spellId
		for i = 1, 40 do
			-- local name, _, _, auraType, _, _, _, _, _, spellId = UnitDebuff(unit, i)
			aura = C_UnitAuras.GetDebuffDataByIndex(unit, i)
			if aura then
				name = aura.name
				auraType = aura.dispelName
				spellId = aura.spellId
			end
			if name then
				if lib:CheckHelpDispel(auraType) then
					if type(usablefunc) == "function" then
						if usablefunc(name, spellId) then
							return name

						end
					elseif type(usablefunc) == "table" then
						if not usablefunc[name] and not usablefunc[auraID] then
							return name
						end
					else
						return name

					end
				end
			else
				break
			end
		end
	end
	return nil
end

function lib:DispelHarm(unit, usablefunc)
	if lib.harm or lib.tranquilize then
		local aura, name, auraType, auraID
		for i = 1, 40 do
--			local name, _, _, auraType, _, _, _, _, _, auraID = UnitBuff(unit, i)
			aura = C_UnitAuras.GetDebuffDataByIndex(unit,i)
			if aura then
				name = aura.name
				auraType = aura.dispelName
				auraID = aura.spellId
			end

			if name then
				if lib:CheckHarmDispel(auraType, auraID) then
					if type(usablefunc) == "function" then
						if usablefunc(name) then
							return name
						end
					elseif type(usablefunc) == "table" then
						if not usablefunc[name] and not usablefunc[auraID] then
							return name
						end
					else

						return name

					end
				end
			else
				break
			end
		end
	end
	return nil
end

function lib:Dispel(unit, usablefunc)
	if UnitCanAttack("player", unit) then
		return lib:DispelHarm(unit, usablefunc)
	elseif UnitCanAssist("player", unit) then
		return lib:DispelHelp(unit, usablefunc)
	else
		return nil
	end
end

local p_help, p_tranquilize, p_harm = {}

lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:UnregisterAllEvents()
lib.frame:RegisterEvent("PLAYER_LOGIN")
lib.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
lib.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
lib.frame:RegisterEvent("SPELLS_CHANGED")
lib.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
lib.frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
lib.frame:SetScript("OnEvent", function()
	p_tranquilize = lib.tranquilize
	p_harm = lib.harm
	wipe(p_help)
	for p in pairs(lib.help) do
		p_help[p] = true
	end
	scanDispel()
	if lib.tranquilize ~= p_tranquilize or p_harm ~= lib.harm then
		return lib.Callbacks:Fire("Update")
	end
	for p in pairs(DebuffTypeSymbol) do
		if lib.help[p] ~= p_help[p] then
			return lib.Callbacks:Fire("Update")
		end
	end
end)
if IsLoggedIn() then
	lib.frame:GetScript("OnEvent")(lib.frame)
end