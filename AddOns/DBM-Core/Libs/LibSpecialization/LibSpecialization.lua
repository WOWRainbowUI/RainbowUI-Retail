--@curseforge-project-slug: libspecialization@
local wowID = WOW_PROJECT_ID
local isRetail = wowID == 1
local isCata = wowID == 14
local isMists = wowID == 19
local isForever = wowID == 18
if not isRetail and not isCata and not isMists and not isForever then return end -- Retail, Cata, Mists, Forever

local LS, oldminor = LibStub:NewLibrary("LibSpecialization", 32)
if not LS then return end -- No upgrade needed

LS.callbackMapGroup = LS.callbackMapGroup or {}
LS.callbackMapGuild = LS.callbackMapGuild or {}
LS.callbackMapPlayerSpecChange = LS.callbackMapPlayerSpecChange or {}
LS.frame = LS.frame or CreateFrame("Frame")

-- Positions of roles
local positionTable = isCata and {
	-- Death Knight
	[398] = "MELEE", -- Blood (Tank)
	[399] = "MELEE", -- Frost (DPS)
	[400] = "MELEE", -- Unholy (DPS)
	-- Druid
	[752] = "RANGED", -- Balance (DPS Owl)
	[750] = "MELEE", -- Feral Combat (DPS Cat AND Tank Bear)
	[748] = "RANGED", -- Restoration (Heal)
	-- Hunter
	[811] = "RANGED", -- Beast Mastery
	[807] = "RANGED", -- Marksmanship
	[809] = "RANGED", -- Survival
	-- Mage
	[799] = "RANGED", -- Arcane
	[851] = "RANGED", -- Fire
	[823] = "RANGED", -- Frost
	-- Paladin
	[831] = "RANGED", -- Holy (Heal)
	[839] = "MELEE", -- Protection (Tank)
	[855] = "MELEE", -- Retribution (DPS)
	-- Priest
	[760] = "RANGED", -- Discipline (Heal)
	[813] = "RANGED", -- Holy (Heal)
	[795] = "RANGED", -- Shadow (DPS)
	-- Rogue
	[182] = "MELEE", -- Assassination
	[181] = "MELEE", -- Combat
	[183] = "MELEE", -- Subtlety
	-- Shaman
	[261] = "RANGED", -- Elemental (DPS)
	[263] = "MELEE", -- Enhancement (DPS)
	[262] = "RANGED", -- Restoration (Heal)
	-- Warlock
	[871] = "RANGED", -- Affliction
	[867] = "RANGED", -- Demonology
	[865] = "RANGED", -- Destruction
	-- Warrior
	[746] = "MELEE", -- Arms (DPS)
	[815] = "MELEE", -- Fury (DPS)
	[845] = "MELEE", -- Protection (Tank)
} or isForever and {
	-- Mage
	[11582] = "RANGED", -- Arcane
	[11594] = "RANGED", -- Fire
	[11601] = "RANGED", -- Frost
	-- Druid
	[11328] = "RANGED", -- Balance (DPS Owl)
	[11347] = "MELEE", -- Feral Combat (DPS Cat AND Tank Bear)
	[11340] = "RANGED", -- Restoration (Heal)
	-- Hunter
	[11372] = "RANGED", -- Beast Mastery
	[11371] = "RANGED", -- Marksmanship
	[11370] = "RANGED", -- Survival
	-- Paladin
	[11486] = "RANGED", -- Holy (Heal)
	[11541] = "MELEE", -- Protection (Tank)
	[11559] = "MELEE", -- Retribution (DPS)
	-- Priest
	[11608] = "RANGED", -- Discipline (Heal)
	[11615] = "RANGED", -- Holy (Heal)
	[11622] = "RANGED", -- Shadow Magic (DPS)
	-- Rogue
	[11580] = "MELEE", -- Assassination
	[11573] = "MELEE", -- Combat
	[11572] = "MELEE", -- Subtlety
	-- Shaman
	[11326] = "RANGED", -- Elemental Combat (DPS)
	[11363] = "MELEE", -- Enhancement (DPS)
	[11362] = "RANGED", -- Restoration (Heal)
	-- Warlock
	[11629] = "RANGED", -- Affliction
	[11636] = "RANGED", -- Demonology
	[11637] = "RANGED", -- Destruction
	-- Warrior
	[11650] = "MELEE", -- Arms (DPS)
	[11657] = "MELEE", -- Fury (DPS)
	[11670] = "MELEE", -- Protection (Tank)
} or {
	-- Death Knight
	[250] = "MELEE", -- Blood (Tank)
	[251] = "MELEE", -- Frost (DPS)
	[252] = "MELEE", -- Unholy (DPS)
	-- Demon Hunter
	[577] = "MELEE", -- Havoc (DPS)
	[581] = "MELEE", -- Vengeance (Tank)
	[1480] = "RANGED", -- Devourer (DPS)
	-- Druid
	[102] = "RANGED", -- Balance (DPS Owl)
	[103] = "MELEE", -- Feral (DPS Cat)
	[104] = "MELEE", -- Guardian (Tank Bear)
	[105] = "RANGED", -- Restoration (Heal)
	-- Evoker
	[1467] = "RANGED", -- Devastation (DPS)
	[1468] = "RANGED", -- Preservation (Heal)
	[1473] = "RANGED", -- Augmentation (DPS)
	-- Hunter
	[253] = "RANGED", -- Beast Mastery
	[254] = "RANGED", -- Marksmanship
	[255] = isMists and "RANGED" or "MELEE", -- Survival [Ranged on Mists, Melee on Retail]
	-- Mage
	[62] = "RANGED", -- Arcane
	[63] = "RANGED", -- Fire
	[64] = "RANGED", -- Frost
	-- Monk
	[268] = "MELEE", -- Brewmaster (Tank)
	[269] = "MELEE", -- Windwalker (DPS)
	[270] = "MELEE", -- Mistweaver (Heal)
	-- Paladin
	[65] = isMists and "RANGED" or "MELEE", -- Holy (Heal) [Ranged on Mists, Melee on Retail]
	[66] = "MELEE", -- Protection (Tank)
	[70] = "MELEE", -- Retribution (DPS)
	-- Priest
	[256] = "RANGED", -- Discipline (Heal)
	[257] = "RANGED", -- Holy (Heal)
	[258] = "RANGED", -- Shadow (DPS)
	-- Rogue
	[259] = "MELEE", -- Assassination
	[260] = "MELEE", -- Outlaw [Retail] / Combat [Mists]
	[261] = "MELEE", -- Subtlety
	-- Shaman
	[262] = "RANGED", -- Elemental (DPS)
	[263] = "MELEE", -- Enhancement (DPS)
	[264] = "RANGED", -- Restoration (Heal)
	-- Warlock
	[265] = "RANGED", -- Affliction
	[266] = "RANGED", -- Demonology
	[267] = "RANGED", -- Destruction
	-- Warrior
	[71] = "MELEE", -- Arms (DPS)
	[72] = "MELEE", -- Fury (DPS)
	[73] = "MELEE", -- Protection (Tank)
}
-- Player roles
local roleTable = isCata and {
	-- Death Knight
	[398] = "TANK", -- Blood (Tank)
	[399] = "DAMAGER", -- Frost (DPS)
	[400] = "DAMAGER", -- Unholy (DPS)
	-- Druid
	[752] = "DAMAGER", -- Balance (DPS Owl)
	[750] = "TANK", -- Feral Combat (DPS Cat AND Tank Bear)
	[748] = "HEALER", -- Restoration (Heal)
	-- Hunter
	[811] = "DAMAGER", -- Beast Mastery
	[807] = "DAMAGER", -- Marksmanship
	[809] = "DAMAGER", -- Survival
	-- Mage
	[799] = "DAMAGER", -- Arcane
	[851] = "DAMAGER", -- Fire
	[823] = "DAMAGER", -- Frost
	-- Paladin
	[831] = "HEALER", -- Holy (Heal)
	[839] = "TANK", -- Protection (Tank)
	[855] = "DAMAGER", -- Retribution (DPS)
	-- Priest
	[760] = "HEALER", -- Discipline (Heal)
	[813] = "HEALER", -- Holy (Heal)
	[795] = "DAMAGER", -- Shadow (DPS)
	-- Rogue
	[182] = "DAMAGER", -- Assassination
	[181] = "DAMAGER", -- Combat
	[183] = "DAMAGER", -- Subtlety
	-- Shaman
	[261] = "DAMAGER", -- Elemental (DPS)
	[263] = "DAMAGER", -- Enhancement (DPS)
	[262] = "HEALER", -- Restoration (Heal)
	-- Warlock
	[871] = "DAMAGER", -- Affliction
	[867] = "DAMAGER", -- Demonology
	[865] = "DAMAGER", -- Destruction
	-- Warrior
	[746] = "DAMAGER", -- Arms (DPS)
	[815] = "DAMAGER", -- Fury (DPS)
	[845] = "TANK", -- Protection (Tank)
} or isForever and {
	-- Mage
	[11582] = "DAMAGER", -- Arcane
	[11594] = "DAMAGER", -- Fire
	[11601] = "DAMAGER", -- Frost
	-- Druid
	[11328] = "DAMAGER", -- Balance (DPS Owl)
	[11347] = "TANK", -- Feral Combat (DPS Cat AND Tank Bear)
	[11340] = "HEALER", -- Restoration (Heal)
	-- Hunter
	[11372] = "DAMAGER", -- Beast Mastery
	[11371] = "DAMAGER", -- Marksmanship
	[11370] = "DAMAGER", -- Survival
	-- Paladin
	[11486] = "HEALER", -- Holy (Heal)
	[11541] = "TANK", -- Protection (Tank)
	[11559] = "DAMAGER", -- Retribution (DPS)
	-- Priest
	[11608] = "HEALER", -- Discipline (Heal)
	[11615] = "HEALER", -- Holy (Heal)
	[11622] = "DAMAGER", -- Shadow Magic (DPS)
	-- Rogue
	[11580] = "DAMAGER", -- Assassination
	[11573] = "DAMAGER", -- Combat
	[11572] = "DAMAGER", -- Subtlety
	-- Shaman
	[11326] = "DAMAGER", -- Elemental Combat (DPS)
	[11363] = "DAMAGER", -- Enhancement (DPS)
	[11362] = "HEALER", -- Restoration (Heal)
	-- Warlock
	[11629] = "DAMAGER", -- Affliction
	[11636] = "DAMAGER", -- Demonology
	[11637] = "DAMAGER", -- Destruction
	-- Warrior
	[11650] = "DAMAGER", -- Arms (DPS)
	[11657] = "DAMAGER", -- Fury (DPS)
	[11670] = "TANK", -- Protection (Tank)
} or {
	-- Death Knight
	[250] = "TANK", -- Blood (Tank)
	[251] = "DAMAGER", -- Frost (DPS)
	[252] = "DAMAGER", -- Unholy (DPS)
	-- Demon Hunter
	[577] = "DAMAGER", -- Havoc (DPS)
	[581] = "TANK", -- Vengeance (Tank)
	[1480] = "DAMAGER", -- Devourer (DPS)
	-- Druid
	[102] = "DAMAGER", -- Balance (DPS Owl)
	[103] = "DAMAGER", -- Feral (DPS Cat)
	[104] = "TANK", -- Guardian (Tank Bear)
	[105] = "HEALER", -- Restoration (Heal)
	-- Evoker
	[1467] = "DAMAGER", -- Devastation (DPS)
	[1468] = "HEALER", -- Preservation (Heal)
	[1473] = "DAMAGER", -- Augmentation (DPS)
	-- Hunter
	[253] = "DAMAGER", -- Beast Mastery
	[254] = "DAMAGER", -- Marksmanship
	[255] = "DAMAGER", -- Survival
	-- Mage
	[62] = "DAMAGER", -- Arcane
	[63] = "DAMAGER", -- Fire
	[64] = "DAMAGER", -- Frost
	-- Monk
	[268] = "TANK", -- Brewmaster (Tank)
	[269] = "DAMAGER", -- Windwalker (DPS)
	[270] = "HEALER", -- Mistweaver (Heal)
	-- Paladin
	[65] = "HEALER", -- Holy (Heal)
	[66] = "TANK", -- Protection (Tank)
	[70] = "DAMAGER", -- Retribution (DPS)
	-- Priest
	[256] = "HEALER", -- Discipline (Heal)
	[257] = "HEALER", -- Holy (Heal)
	[258] = "DAMAGER", -- Shadow (DPS)
	-- Rogue
	[259] = "DAMAGER", -- Assassination
	[260] = "DAMAGER", -- Outlaw [Retail] / Combat [Mists]
	[261] = "DAMAGER", -- Subtlety
	-- Shaman
	[262] = "DAMAGER", -- Elemental (DPS)
	[263] = "DAMAGER", -- Enhancement (DPS)
	[264] = "HEALER", -- Restoration (Heal)
	-- Warlock
	[265] = "DAMAGER", -- Affliction
	[266] = "DAMAGER", -- Demonology
	[267] = "DAMAGER", -- Destruction
	-- Warrior
	[71] = "DAMAGER", -- Arms (DPS)
	[72] = "DAMAGER", -- Fury (DPS)
	[73] = "TANK", -- Protection (Tank)
}
-- Starter specs
local starterSpecs = isCata and {
} or isForever and {
	[1482] = true, -- Mage
	[1484] = true, -- Druid
	[1485] = true, -- Hunter
	[1486] = true, -- Paladin
	[1487] = true, -- Priest
	[1488] = true, -- Rogue
	[1489] = true, -- Shaman
	[1490] = true, -- Warlock
	[1491] = true, -- Warrior
} or { -- Retail & Mists
	[1444] = true, -- Shaman
	[1446] = true, -- Warrior
	[1447] = true, -- Druid
	[1448] = true, -- Hunter
	[1449] = true, -- Mage
	[1450] = true, -- Monk
	[1451] = true, -- Paladin
	[1452] = true, -- Priest
	[1453] = true, -- Rogue
	[1454] = true, -- Warlock
	[1455] = true, -- Death Knight
	[1456] = true, -- Demon Hunter
	[1465] = true, -- Evoker
}

local callbackMapGroup = LS.callbackMapGroup
local callbackMapGuild = LS.callbackMapGuild
local callbackMapPlayerSpecChange = LS.callbackMapPlayerSpecChange

local type, error, format, tostring = type, error, string.format, tostring
local geterrorhandler, GetTime = geterrorhandler, GetTime

do
	local result = C_ChatInfo.RegisterAddonMessagePrefix("LibSpec")
	-- 0=success, 1=duplicate, 2=invalid, 3=toomany
	if type(result) == "number" and result > 1 then
		error("LibSpecialization: Failed to register the addon prefix.")
		return
	end
end

-- Handle groups (comms are automatic)
function LS.RegisterGroup(addon, func)
	if type(addon) ~= "table" or addon == LS then
		error("LibSpecialization: The function lib.RegisterGroup expects your own unique table as the first arg.", 2)
	elseif type(func) == "function" then
		callbackMapGroup[addon] = func
	else
		error("LibSpecialization: The function lib.RegisterGroup expects your own function as the second arg.", 2)
	end
end

function LS.UnregisterGroup(addon)
	if type(addon) ~= "table" or addon == LS then
		error("LibSpecialization: The function lib.UnregisterGroup expects your own unique table.", 2)
	else
		callbackMapGroup[addon] = nil
	end
end

-- Handle guilds (comms are on manual request)
function LS.RegisterGuild(addon, func)
	if type(addon) ~= "table" or addon == LS then
		error("LibSpecialization: The function lib.RegisterGuild expects your own unique table as the first arg.", 2)
	elseif type(func) == "function" then
		callbackMapGuild[addon] = func
	else
		error("LibSpecialization: The function lib.RegisterGuild expects your own function as the second arg.", 2)
	end
end

function LS.UnregisterGuild(addon)
	if type(addon) ~= "table" or addon == LS then
		error("LibSpecialization: The function lib.UnregisterGuild expects your own unique table.", 2)
	else
		callbackMapGuild[addon] = nil
	end
end

function LS.RegisterPlayerSpecChange(addon, func)
	if type(addon) ~= "table" or addon == LS then
		error("LibSpecialization: The function lib.RegisterPlayerSpecChange expects your own unique table as the first arg.", 2)
	elseif type(func) == "function" then
		callbackMapPlayerSpecChange[addon] = func
	else
		error("LibSpecialization: The function lib.RegisterPlayerSpecChange expects your own function as the second arg.", 2)
	end
end

function LS.UnregisterPlayerSpecChange(addon)
	if type(addon) ~= "table" or addon == LS then
		error("LibSpecialization: The function lib.UnregisterPlayerSpecChange expects your own unique table.", 2)
	else
		callbackMapPlayerSpecChange[addon] = nil
	end
end

local GetInfo
if isCata then
	function GetInfo()
		local specIndex = GetPrimaryTalentTree()
		if specIndex then
			local specId = GetTalentTabInfo(specIndex)
			if type(specId) == "number" and specId > 0 then
				local position = positionTable[specId]
				local role = roleTable[specId]
				if position and role then
					if specId == 750 and not C_SpellBook.IsSpellKnownOrInSpellBook(57880) then -- Cataclysm Feral Druids, if you don't have 2 points in 'Natural Reaction' we assume you're a cat
						return specId, "DAMAGER", position
					end
					return specId, role, position
				else
					geterrorhandler()(format("LibSpecialization: Unknown spec ID %q", specId))
				end
			end
		end
	end
elseif isMists then
	local GetSpecialization, GetSpecializationInfo = C_SpecializationInfo.GetSpecialization, C_SpecializationInfo.GetSpecializationInfo
	local GetTalentInfo, GetGlyphSocketInfo = C_SpecializationInfo.GetTalentInfo, GetGlyphSocketInfo
	local SerializeJSON = C_EncodingUtil.SerializeJSON
	local talentQuery = {}
	function GetInfo()
		local spec = GetSpecialization()
		if type(spec) == "number" and spec > 0 then
			local specId = GetSpecializationInfo(spec)

			if type(specId) == "number" and specId > 0 then
				local position = positionTable[specId]
				local role = roleTable[specId]
				if position and role then
					local storageTable = {
						talents = {0, 0, 0, 0, 0, 0}, -- 6 tiers/rows
						glyphs = {0, 0, 0, 0, 0, 0}, -- 6 glyphs
					}

					-- Fill in the talents
					for tier = 1, 6 do -- 6 rows
						talentQuery.tier = tier
						for column = 1, 3 do -- 3 columns
							talentQuery.column = column
							local talentInfo = GetTalentInfo(talentQuery)
							if talentInfo and talentInfo.known and type(talentInfo.talentID) == "number" then
								storageTable.talents[tier] = talentInfo.talentID
								break
							end
						end
					end

					-- Fill in the glyphs
					for glyphSlot = 1, 6 do -- There are 6 glyphs in total, 3 major and 3 minor
						local _, _, _, _, _, glyphID = GetGlyphSocketInfo(glyphSlot)
						if type(glyphID) == "number" then
							storageTable.glyphs[glyphSlot] = glyphID
						end
					end

					local talentsAndGlyphsJSON = SerializeJSON(storageTable)
					return specId, role, position, talentsAndGlyphsJSON
				elseif not starterSpecs[specId] then
					geterrorhandler()(format("LibSpecialization: Unknown spec ID %q", specId))
				end
			end
		end
	end
elseif isForever then
	local C_Traits_GenerateImportString, C_Traits_GetConfigInfo, C_Traits_GetNodeInfo = C_Traits.GenerateImportString, C_Traits.GetConfigInfo, C_Traits.GetNodeInfo
	local C_Traits_GetEntryInfo, C_Traits_GetDefinitionInfo = C_Traits.GetEntryInfo, C_Traits.GetDefinitionInfo
	local C_Traits_GetGroupDisplayInfoByTreeID, C_Traits_GetGroupCurrencyInfo = C_Traits.GetGroupDisplayInfoByTreeID, C_Traits.GetGroupCurrencyInfo
	local C_ClassTalents_GetActiveConfigID = C_ClassTalents.GetActiveConfigID
	local GetSpecialization, GetSpecializationInfo = C_SpecializationInfo.GetSpecialization, C_SpecializationInfo.GetSpecializationInfo
	function GetInfo()
		local spec = GetSpecialization()
		if type(spec) == "number" and spec > 0 then
			local specId = GetSpecializationInfo(spec)
			if type(specId) == "number" and specId > 0 then
				local position, role
				local activeConfigID = C_ClassTalents_GetActiveConfigID()
				if starterSpecs[specId] then -- Forever ONLY has starter specs
					if activeConfigID then
						local configInfoTbl = C_Traits_GetConfigInfo(activeConfigID)
						local treeID = type(configInfoTbl) == "table" and type(configInfoTbl.treeIDs) == "table" and configInfoTbl.treeIDs[1] or nil
						if type(treeID) == "number" then
							local groupInfoTbl = C_Traits_GetGroupDisplayInfoByTreeID(treeID)
							if type(groupInfoTbl) == "table" then
								local groupIDTable = {}
								for i = 1, #groupInfoTbl do
									local groupID = groupInfoTbl[i].groupID
									if type(groupID) == "number" then
										if roleTable[groupID] then
											groupIDTable[#groupIDTable+1] = groupID
										else
											geterrorhandler()(format("LibSpecialization: Unknown group ID %q", groupID))
										end
									end
								end
								if #groupIDTable > 0 then
									local currencyInfoTbl = C_Traits_GetGroupCurrencyInfo(activeConfigID, groupIDTable)
									if type(currencyInfoTbl) == "table" then
										local bestGroupID, bestSpent = nil, 0
										for i = 1, #currencyInfoTbl do
											local info = currencyInfoTbl[i]
											if type(info) == "table" and type(info.traitNodeGroupID) == "number" and type(info.currencyInfos) == "table" then
												local currencyInfo = info.currencyInfos[1]
												local spent = type(currencyInfo) == "table" and currencyInfo.spent or nil
												if type(spent) == "number" and spent > 0 then
													local groupID = info.traitNodeGroupID
													if spent > bestSpent or (spent == bestSpent and groupID < bestGroupID) then
														bestSpent = spent
														bestGroupID = groupID
													end
												end
											end
										end
										if bestGroupID then -- The group ID with the most points spent decides the role and position
											role = roleTable[bestGroupID]
											position = positionTable[bestGroupID]
											specId = bestGroupID
											if specId == 11347 then -- Forever Feral Druids: 3 points in "Shredding Attacks" (node 104945) = DAMAGER, otherwise TANK
												local nodeInfo = C_Traits_GetNodeInfo(activeConfigID, 104945)
												local entryID = type(nodeInfo) == "table" and type(nodeInfo.entryIDs) == "table" and nodeInfo.entryIDs[1] or nil
												local entryInfo = entryID and C_Traits_GetEntryInfo(activeConfigID, entryID) or nil
												local definitionID = type(entryInfo) == "table" and entryInfo.definitionID or nil
												local definitionInfo = definitionID and C_Traits_GetDefinitionInfo(definitionID) or nil
												local spellID = type(definitionInfo) == "table" and definitionInfo.spellID or nil
												local maxRanks = type(nodeInfo) == "table" and nodeInfo.maxRanks or nil
												if spellID == 16966 and maxRanks == 3 then
													if nodeInfo.ranksPurchased == 3 then
														role = "DAMAGER"
													end
												else
													local errSpell, errRanks = tostring(spellID), tostring(maxRanks)
													geterrorhandler()(format("LibSpecialization: Unexpected Feral node 104945 (spellID: %s, maxRanks: %s)", errSpell, errRanks))
												end
											end
										end
									end
								end
							end
						end
					end
				else
					geterrorhandler()(format("LibSpecialization: Unknown spec ID %q", specId))
				end

				if position and role then
					-- On Forever, each class only has 1 spec ID, so that's not useful.
					-- Each class also only has 1 tree ID, which is also not useful.
					-- But within each tree is multiple groups, and that's useful for differentiating specs.
					-- The group ID is what we'd consider to be the "tree" e.g. "Arms" on a Warrior, but Blizz uses different terminology.
					-- So on Forever we send the talent group ID instead of the spec ID or the tree ID.
					local talentString = C_Traits_GenerateImportString(activeConfigID)
					return specId, role, position, talentString
				end
			end
		end
	end
else
	local C_Traits_GenerateImportString = C_Traits.GenerateImportString
	local C_ClassTalents_GetActiveConfigID = C_ClassTalents.GetActiveConfigID
	local GetSpecialization, GetSpecializationInfo = C_SpecializationInfo.GetSpecialization, C_SpecializationInfo.GetSpecializationInfo
	function GetInfo()
		local spec = GetSpecialization()
		if type(spec) == "number" and spec > 0 then
			local specId = GetSpecializationInfo(spec)

			if type(specId) == "number" and specId > 0 then
				local position = positionTable[specId]
				local role = roleTable[specId]
				if position and role then
					local activeConfigID = C_ClassTalents_GetActiveConfigID()
					if activeConfigID then
						local talentString = C_Traits_GenerateImportString(activeConfigID)
						return specId, role, position, talentString
					end
					return specId, role, position
				elseif not starterSpecs[specId] then
					geterrorhandler()(format("LibSpecialization: Unknown spec ID %q", specId))
				end
			end
		end
	end
end
LS.MySpecialization = GetInfo

local throttleTime = 3 -- Seconds
local pName
if RegionalUniqueNamesEnabled and RegionalUniqueNamesEnabled() then
	local name, surname = UnitNameUnmodified("player")
	pName = name .. " " .. surname
else
	pName = UnitNameUnmodified("player")
end
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local IsInGroup, IsInGuild = IsInGroup, IsInGuild
local InChatMessagingLockdown = C_ChatInfo.InChatMessagingLockdown
local CTimerNewTimer = C_Timer.NewTimer
local next, securecallfunction = next, securecallfunction
local statusCheckTable = {
	INSTANCE_CHAT = function() return IsInGroup(2) end,
	RAID = function() return IsInGroup(1) end, -- RAID auto downgrades to PARTY as needed
	GUILD = IsInGuild,
}
local RequestGroupSpecialization
do
	local throttleSendTable = {
		INSTANCE_CHAT = 0,
		RAID = 0,
		GUILD = 0,
	}
	local retryCount = {
		INSTANCE_CHAT = 0,
		RAID = 0,
		GUILD = 0,
	}
	local timers = {}
	local requestFunctionTable
	local function SendRequest(channel)
		if timers[channel] then
			timers[channel]:Cancel()
			timers[channel] = nil
		end
		if statusCheckTable[channel]() then
			if InChatMessagingLockdown() then
				if channel ~= "GUILD" then
					LS.frame:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
				end
			else
				throttleSendTable[channel] = GetTime()
				local result = SendAddonMessage("LibSpec", "R", channel)
				if (result == 3 or result == 8 or result == 9) and retryCount[channel] < 5 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
					retryCount[channel] = retryCount[channel] + 1
					timers[channel] = CTimerNewTimer(throttleTime, requestFunctionTable[channel])
					return
				end
			end
		end
		retryCount[channel] = 0
	end
	local function SendRequestInstance()
		SendRequest("INSTANCE_CHAT")
	end
	local function SendRequestGroup()
		SendRequest("RAID") -- RAID auto downgrades to PARTY as needed
	end
	local function SendRequestGuild()
		SendRequest("GUILD")
	end
	requestFunctionTable = {
		INSTANCE_CHAT = SendRequestInstance,
		RAID = SendRequestGroup,
		GUILD = SendRequestGuild,
	}
	local function PrepareRequest(channel, t, scheduleFollowup)
		if t - throttleSendTable[channel] > throttleTime then
			requestFunctionTable[channel]()
			if scheduleFollowup and not timers[channel] then
				-- Schedule a delayed request in case we requested group data a millisecond too early,
				-- and not everyone in the group was out of chat lockdown to hear our request.
				timers[channel] = CTimerNewTimer(throttleTime+0.1, requestFunctionTable[channel])
			end
		elseif not timers[channel] then
			timers[channel] = CTimerNewTimer((throttleTime+0.1)-(t-throttleSendTable[channel]), requestFunctionTable[channel])
		end
	end
	function RequestGroupSpecialization(scheduleFollowup)
		local specId, role, position, talentString = GetInfo()
		if specId then
			for _,func in next, callbackMapGroup do
				securecallfunction(func, specId, role, position, pName, talentString) -- This allows us to show our own spec info when not grouped
			end
		end

		if IsInGroup() then
			if InChatMessagingLockdown() then
				LS.frame:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
				return
			end

			local t = GetTime()
			if IsInGroup(2) then
				PrepareRequest("INSTANCE_CHAT", t, scheduleFollowup)
			end
			if IsInGroup(1) then
				PrepareRequest("RAID", t, scheduleFollowup)
			end
		end
	end
	function LS.RequestGuildSpecialization() -- Guild comms are manual, you will need to manually request data each time
		local specId, role, position, talentString = GetInfo()
		if specId then
			for _,func in next, callbackMapGuild do
				securecallfunction(func, specId, role, position, pName, talentString) -- This allows us to show our own spec info when not in a guild
			end
		end

		if not InChatMessagingLockdown() and IsInGuild() then
			local t = GetTime()
			PrepareRequest("GUILD", t)
		end
	end
end

do
	local throttleTable = {
		INSTANCE_CHAT = 0,
		RAID = 0,
		GUILD = 0,
	}
	local timerTable = {}
	local retryCount = {
		INSTANCE_CHAT = 0,
		RAID = 0,
		GUILD = 0,
	}
	local functionTable
	local function SendToChannel(channel)
		if timerTable[channel] then
			timerTable[channel]:Cancel()
			timerTable[channel] = nil
		end
		if statusCheckTable[channel]() then
			if InChatMessagingLockdown() then
				if channel ~= "GUILD" then
					LS.frame:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
				end
			else
				local specId, role, _, talentString = GetInfo()
				if specId then
					local msg
					if specId == 750 then -- Cataclysm Feral Druids
						msg = format("%d,,%s", specId, role)
					elseif specId == 11347 then -- Forever Feral Druids
						msg = format("%d,%s,%s", specId, talentString or "", role)
					else
						msg = format("%d,%s", specId, talentString or "")
					end
					throttleTable[channel] = GetTime()
					local result = SendAddonMessage("LibSpec", msg, channel)
					if (result == 3 or result == 8 or result == 9) and retryCount[channel] < 5 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
						retryCount[channel] = retryCount[channel] + 1
						timerTable[channel] = CTimerNewTimer(throttleTime, functionTable[channel])
						return
					end
				end
			end
		end
		retryCount[channel] = 0
	end
	local function SendToInstance()
		SendToChannel("INSTANCE_CHAT")
	end
	local function SendToGroup()
		SendToChannel("RAID") -- RAID auto downgrades to PARTY as needed
	end
	local function SendToGuild()
		SendToChannel("GUILD")
	end
	functionTable = {
		INSTANCE_CHAT = SendToInstance,
		RAID = SendToGroup,
		GUILD = SendToGuild,
	}
	local function PrepareChannel(channel)
		if InChatMessagingLockdown() then return end
		local t = GetTime()
		if t - throttleTable[channel] > throttleTime then
			functionTable[channel]()
		elseif not timerTable[channel] then
			timerTable[channel] = CTimerNewTimer((throttleTime+0.1)-(t-throttleTable[channel]), functionTable[channel])
		end
	end

	local approved = {
		RAID = callbackMapGroup,
		PARTY = callbackMapGroup,
		INSTANCE_CHAT = callbackMapGroup,
		GUILD = callbackMapGuild,
	}
	local tonumber, strsplit = tonumber, string.split
	local Ambiguate = Ambiguate
	local C_ClassTalents_GetActiveConfigID = C_ClassTalents and C_ClassTalents.GetActiveConfigID
	LS.frame:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
		if event == "CHAT_MSG_ADDON" then
			if prefix == "LibSpec" and approved[channel] then -- Only approved channels
				if msg == "R" then
					PrepareChannel(channel == "PARTY" and "RAID" or channel)
					return
				end

				local spec, talentString = strsplit(",", msg, 2)
				local specId = tonumber(spec)
				local role, position = roleTable[specId], positionTable[specId]
				if talentString and role and position then
					if specId == 750 then -- Cataclysm Feral Druids (no talent string: "750,,TANK" or "750,,DAMAGER")
						if talentString == ",TANK" then
							role = "TANK"
						elseif talentString == ",DAMAGER" then
							role = "DAMAGER"
						else
							return
						end
						talentString = nil
					elseif specId == 11347 then -- Forever Feral Druids ("11347,<talentString>,TANK" or "11347,<talentString>,DAMAGER")
						local druidTalents, druidRole = strsplit(",", talentString, 2)
						if druidRole == "TANK" or druidRole == "DAMAGER" then
							role = druidRole
							talentString = druidTalents
						elseif druidRole then -- Reject malformed role, but allow older clients omitting role (defaults to TANK)
							return
						end
					end
					local playerName = Ambiguate(sender, "none")
					local talents = talentString and #talentString > 2 and talentString or nil
					for _,func in next, approved[channel] do
						securecallfunction(func, specId, role, position, playerName, talents)
					end
				end
			end
		elseif event == "PLAYER_TALENT_UPDATE" or event == "GLYPH_ADDED" or event == "GLYPH_REMOVED" or event == "GLYPH_UPDATED" or event == "PLAYER_SPECIALIZATION_CHANGED" or ((event == "ACTIVE_COMBAT_CONFIG_CHANGED" or event == "TRAIT_CONFIG_UPDATED") and prefix == C_ClassTalents_GetActiveConfigID()) then
			for _,func in next, callbackMapPlayerSpecChange do
				securecallfunction(func) -- Notify when the player has changed their spec
			end
			local specId, role, position, talentString = GetInfo()
			if specId then
				for _,func in next, callbackMapGroup do
					securecallfunction(func, specId, role, position, pName, talentString)
				end
			end
			if IsInGroup() then
				if InChatMessagingLockdown() then
					self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
				else
					if IsInGroup(2) then -- Instance group
						PrepareChannel("INSTANCE_CHAT")
					end
					if IsInGroup(1) then -- Normal group
						PrepareChannel("RAID")
					end
				end
			end
		elseif event == "GROUP_FORMED" then -- Join new group
			RequestGroupSpecialization()
		elseif event == "PLAYER_LOGIN" then
			RequestGroupSpecialization(true)
			-- Some addons don't care about group specs and only use the player callbacks, trigger those on log in
			for _,func in next, callbackMapPlayerSpecChange do
				securecallfunction(func)
			end
		elseif event == "ADDON_RESTRICTION_STATE_CHANGED" then
			if not InChatMessagingLockdown() then
				self:UnregisterEvent(event)
				RequestGroupSpecialization(true)
			end
		end
	end)
	LS.frame:RegisterEvent("CHAT_MSG_ADDON")
	LS.frame:RegisterEvent("GROUP_FORMED")
	if isCata then
		LS.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	elseif isMists then
		LS.frame:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
		LS.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
		LS.frame:RegisterEvent("GLYPH_ADDED")
		LS.frame:RegisterEvent("GLYPH_REMOVED")
		LS.frame:RegisterEvent("GLYPH_UPDATED")
	else -- Retail & Forever
		LS.frame:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED")
		LS.frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
	end
	if not IsLoggedIn() then
		LS.frame:RegisterEvent("PLAYER_LOGIN")
	elseif not oldminor then -- Player is logged in and library isn't upgrading
		C_Timer.After(0, function()
			RequestGroupSpecialization()
			for _,func in next, callbackMapPlayerSpecChange do
				securecallfunction(func)
			end
		end)
	end
end

function LS.RequestGroupSpecialization()
	-- DEPRECATED. This function was never supposed to be used as this library handles communication automatically.
	-- Unfortunately bad devs or bad AI started overusing this function, creating a lot of transmission noise on pointless ingame events.
end
