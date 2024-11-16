local IUF = InvenUnitFrames
local handlers = IUF.handlers
handlers:Hide()

local _G = _G
local type = _G.type
local unpack = _G.unpack
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local tinsert = _G.table.insert
local IsResting = _G.IsResting
local UnitExists = _G.UnitExists
local UnitIsUnit = _G.UnitIsUnit
local UnitGUID = _G.UnitGUID
local UnitIsVisible = _G.UnitIsVisible
local UnitIsAFK = _G.UnitIsAFK
local UnitName = _G.UnitName
local UnitIsPlayer = _G.UnitIsPlayer
local UnitClass = _G.UnitClass
local UnitLevel = _G.UnitLevel
local UnitClassification = _G.UnitClassification
local UnitCanAttack = _G.UnitCanAttack
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitIsDead = _G.UnitIsDead
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitIsConnected =_G.UnitIsConnected
local UnitIsTapped = _G.UnitIsTapped
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitIsTappedByPlayer = _G.UnitIsTappedByPlayer
local UnitIsTappedByAllThreatList = _G.UnitIsTappedByAllThreatList
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local GetComboPoints = _G.GetComboPoints
local GetLootMethod = _G.GetLootMethod
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local UnitCreatureType = _G.UnitCreatureType
local UnitThreatSituation = _G.UnitThreatSituation
local UnitAlternatePowerInfo = _G.UnitAlternatePowerInfo
local GetUnitPowerBarInfo = _G.GetUnitPowerBarInfo
local UnitGetIncomingHeals = _G.UnitGetIncomingHeals
local UnitIsQuestBoss = _G.UnitIsQuestBoss

local targetFrame, targetUnit, _

local updateEvents = { "OnUpdate", "UNIT_NAME_UPDATE", "UNIT_MAXHEALTH", "UNIT_HEALTH", "UNIT_DISPLAYPOWER", "RAID_TARGET_UPDATE", "PLAYER_UPDATE_RESTING", "UNIT_SPELLCAST_START", "UNIT_AURA", "UNIT_POWER_UPDATE", "UNIT_HEAL_PREDICTION" }
--local updateEvents = { "OnUpdate", "UNIT_NAME_UPDATE", "UNIT_MAXHEALTH", "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_DISPLAYPOWER", "RAID_TARGET_UPDATE", "PLAYER_UPDATE_RESTING", "UNIT_SPELLCAST_START", "UNIT_AURA", "UNIT_POWER_UPDATE", "UNIT_HEAL_PREDICTION" }

local creatureTypes = {
	["야수"] = true, ["Beast"] = true,
	["악마"] = true, ["Demon"] = true,
	["용족"] = true, ["Dragonkin"] = true,
	["정령"] = true, ["Elemental"] = true,
	["거인"] = true, ["Giant"] = true,
	["인간형"] = true, ["Humanoid"] = true,
	["기계"] = true, ["Mechanical"] = true,
	["언데드"] = true, ["Undead"] = true,
}
local factionGroups = { ["Horde"] = 1, ["Alliance"] = 2 }

function IUF:UpdateObject(object)
	if object.unit and UnitExists(object.unit) then
		handlers.PLAYER_ENTERING_WORLD(object)
		IUF:RefreshObject(object)
	end
end

function IUF:UpdateAllObject()
	for _, object in pairs(self.units) do

		self:UpdateObject(object)
	end
end

function IUF:RegisterHandlerEvents()
	self.RegisterHandlerEvents = nil
	self:RegisterObjectValueHandler("guid", "Update", "Portrait")
	self:RegisterObjectValueHandler("connect", "Portrait", "OfflineIcon", "State", "StateColor", "PetAlpha")
	self:RegisterObjectValueHandler("modelfile", "Portrait")
	self:RegisterObjectValueHandler("visible", "Portrait")
	self:RegisterObjectValueHandler("name", "Name")
	self:RegisterObjectValueHandler("group", "Name")
	self:RegisterObjectValueHandler("class", "Class", "NameColor", "HealthColor")
	self:RegisterObjectValueHandler("creature", "Class")
	self:RegisterObjectValueHandler("faction", "NameColor", "HealthColor", "BarFill")
	self:RegisterObjectValueHandler("vehicle", "NameColor", "HealthColor", "UpdateAllCombo")
	self:RegisterObjectValueHandler("player", "Class", "BarFill")
	self:RegisterObjectValueHandler("classification", "Class", "Elite")
	self:RegisterObjectValueHandler("race", "Race")
	self:RegisterObjectValueHandler("level", "Level")
	self:RegisterObjectValueHandler("elite", "Level")
	self:RegisterObjectValueHandler("health", "Health", "Heal")
	self:RegisterObjectValueHandler("healthmax", "Health", "Heal")
	self:RegisterObjectValueHandler("powertype", "PowerColor")
	self:RegisterObjectValueHandler("power", "Power")
	self:RegisterObjectValueHandler("powermax", "Power")
	self:RegisterObjectValueHandler("afk", "State")
	self:RegisterObjectValueHandler("dead", "State", "StateColor")
	self:RegisterObjectValueHandler("ghost", "State", "StateColor")
	self:RegisterObjectValueHandler("tapped", "NameColor", "HealthColor", "BarFill", "State", "StateColor")
	self:RegisterObjectValueHandler("aggro", "Aggro")
	self:RegisterObjectValueHandler("threatvalue", "State")
	self:RegisterObjectValueHandler("threatstatus", "StateColor")
	self:RegisterObjectValueHandler("combat", "CombatIcon", "Health", "Power")
	self:RegisterObjectValueHandler("resting", "CombatIcon")
	self:RegisterObjectValueHandler("raidtarget", "RaidIcon")
	self:RegisterObjectValueHandler("leader", "LeaderIcon")
	self:RegisterObjectValueHandler("looter", "LootIcon")
	self:RegisterObjectValueHandler("pvp", "PvPIcon", "BarFill")
	self:RegisterObjectValueHandler("castingEndTime", "CastingBar")
	self:RegisterObjectValueHandler("castingIsShield", "CastingBarColor")
	self:RegisterObjectValueHandler("castingIsChannel", "CastingBarColor")
	self:RegisterObjectValueHandler("dispel", "Dispel")
	self:RegisterObjectValueHandler("role", "Role", "Level")
	self:RegisterObjectValueHandler("combo", "Combo")
	self:RegisterObjectValueHandler("heal", "Heal")
	handlers:RegisterEvent("PLAYER_ENTERING_WORLD")
	handlers:RegisterEvent("PLAYER_TARGET_CHANGED")
	handlers:RegisterEvent("PLAYER_FOCUS_CHANGED")
	handlers:RegisterEvent("PLAYER_UPDATE_RESTING")
	handlers:RegisterEvent("GROUP_ROSTER_UPDATE")
	handlers:RegisterEvent("RAID_TARGET_UPDATE")
	handlers:RegisterEvent("PARTY_LEADER_CHANGED")
	handlers:RegisterEvent("GROUP_LEFT")
	handlers:RegisterEvent("READY_CHECK")
	handlers:RegisterUnitEvent("UNIT_POWER_UPDATE", "player", "vehicle")
	if self.RegisterClassBarHandlerEvents then
		self:RegisterClassBarHandlerEvents()
	end
	handlers:Show()
end

function IUF:RegisterUpdateEvent(event, func, isUpdate)
	if type(event) == "string" and type(func) == "function" then
		if not(handlers:IsEventRegistered(event) or event == "OnUpdate") then
			handlers:RegisterEvent(event)
			if isUpdate then
				tinsert(updateEvents, event)
			end
		end
		if handlers[event] then
			hooksecurefunc(handlers[event], func)
		else
			handlers[event] = func
		end
		for _, callback in pairs(self.callbacks) do
			if func == callback then
				return
			end
		end
		tinsert(self.callbacks, func)
	end
end

local vehicleParty = { partypet1 = "party1", partypet2 = "party2", partypet3 = "party3", partypet4 = "party4" }
local partyVehicle = { party1 = "partypet1", party2 = "partypet2", party3 = "partypet3", party4 = "partypet4" }

function IUF:GetEventUnitObject(unit)
	if unit == "player" then
		if UnitHasVehicleUI(unit) then
			return self.units.pet
		else
			return self.units.player
		end
	elseif unit == "pet" then
		if UnitHasVehicleUI("player") then
			return self.units.player
		else
			return self.units.pet
		end
	elseif vehicleParty[unit] then
		if UnitHasVehicleUI(vehicleParty[unit]) then
			return self.units[vehicleParty[unit]]
		else
			return self.units[unit]
		end
	elseif partyVehicle[unit] then
		if UnitHasVehicleUI(unit) then
			return nil
		else
			return self.units[unit]
		end
	else
		return self.units[unit]
	end
end

local objectVehicleEvents = {
	["UNIT_ENTERED_VEHICLE"] = true, ["UNIT_EXITED_VEHICLE"] = true, ["UNIT_PET"] = true
}

local function objectOnEvent(object, event, unit, ...)
	if objectVehicleEvents[event] then
		if UnitHasVehicleUI(unit) then
			IUF:UpdateObject(IUF.units[unit])
		elseif IUF.units[unit].petunit and IUF.units[IUF.units[unit].petunit] then
			IUF:UpdateObject(IUF.units[IUF.units[unit].petunit])
		end
	elseif handlers[event] and IUF.links[unit] and IUF.visibleObject[IUF.links[unit]] then
		handlers[event](IUF.links[unit], ...)
	end
end

function IUF:RegisterObjectEvents(object)
	object:RegisterUnitEvent("UNIT_NAME_UPDATE", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_HEALTH", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_MAXHEALTH", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_POWER_UPDATE", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_DISPLAYPOWER", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_MAXPOWER", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_POWER_FREQUENT", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_POWER_BAR_SHOW", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_AURA", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_LEVEL", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_FACTION", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_HEAL_PREDICTION", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_MODEL_CHANGED", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_START", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_STOP", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", object.realunit, object.petunit)
	object:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", object.realunit, object.petunit)
	object:RegisterUnitEvent("READY_CHECK_CONFIRM", object.realunit, object.petunit)
	if object.realunit == "player" or object.objectType == "party" then
		for event in pairs(objectVehicleEvents) do
			object:RegisterUnitEvent(event, object.realunit)
		end
	end
	object:SetScript("OnEvent", objectOnEvent)
end

handlers:SetScript("OnEvent", function(self, event, unit, ...)
	if event == "UNIT_POWER_UPDATE" then
		for object in pairs(IUF.visibleObject) do
			handlers[event](object)
		end
		
	elseif event == "PLAYER_TARGET_CHANGED" then

		unit = "target"
		for i = 1, 3 do
			if IUF.units[unit] then
				IUF.units[unit].values.combo = nil
				if UnitExists(unit) then
					handlers.PLAYER_ENTERING_WORLD(IUF.units[unit])

				end
			end
			unit = unit.."target"

		end
		
		IUF:READY_CHECK()
		
	elseif event == "PLAYER_FOCUS_CHANGED" then
		unit = "focus"
		for i = 1, 3 do
			if IUF.units[unit] then
				IUF.units[unit].values.combo = nil
				if UnitExists(unit) then
					handlers.PLAYER_ENTERING_WORLD(IUF.units[unit])
				end
			end
			unit = unit.."target"
		end
		
		IUF:READY_CHECK()
		
	elseif event == "PLAYER_UPDATE_RESTING" then
		if IUF.units.player then
			handlers[event](IUF.units.player)
		end
		
	elseif event == "GROUP_LEFT" then
		handlers["GROUP_ROSTER_UPDATE"](IUF.units.player)
		
	elseif event == "GROUP_ROSTER_UPDATE" then
		for unit, object in pairs(IUF.units) do
			if unit:find("party") and object.unit and UnitExists(object.unit) then
				if IUF.visibleObject[object] then
					handlers[event](object)
				end
				IUF:UpdateObject(object)
			end
		end
	elseif event == "READY_CHECK" then
		IUF:READY_CHECK()
		
	elseif handlers[event] then
		if unit then
			if IUF.links[unit] and IUF.visibleObject[IUF.links[unit]] then
				handlers[event](IUF.links[unit], ...)
			end
		else
			for object in pairs(IUF.visibleObject) do
				if object.unit and UnitExists(object.unit) then
					handlers[event](object)
				end
			end
		end
	end
end)

handlers:SetScript("OnUpdate", function(self, timer)
	self.timer = (self.timer or 0) + timer
	if self.timer > 0.2 then
		self.timer = 0
		for object in pairs(IUF.visibleObject) do
			if object.needAutoUpdate then
				handlers.PLAYER_ENTERING_WORLD(object)
			else
				handlers.OnUpdate(object)
			end
		end
		if IUF.units.player.watch and IUF.ClassBarOnUpdate then
			IUF:ClassBarOnUpdate(IUF.units.player)
		end
	end
end)

function handlers:OnUpdate()
	if self.unit and UnitExists(self.unit) and self.realunit and UnitExists(self.realunit) then
		self.values.guid = UnitGUID(self.unit)
		self.values.connect = UnitIsConnected(self.realunit)
		self.values.combat = UnitAffectingCombat(self.unit)
		self.values.visible = UnitIsVisible(self.unit)
--		self.values.tapped = UnitIsTapped(self.unit) and not UnitPlayerControlled(self.unit) and not UnitIsTappedByPlayer(self.unit) and not UnitIsTappedByAllThreatList(self.unit)
		self.values.tapped = UnitIsTapDenied(self.unit)
		self.values.afk = (UnitIsAFK(self.unit) or UnitIsAFK(self.realunit)) and 1 or nil
		if self.realunit == "target" then
			if self.values.combat and self.values.attack and not self.values.player then
				self.values.threatstatus, self.values.threatvalue = select(2, UnitDetailedThreatSituation("player", "target"))
			else
				self.values.threatstatus, self.values.threatvalue = nil
			end
		end
	end
end



function handlers:PLAYER_ENTERING_WORLD()
	if self.realunit and self.unit and UnitExists(self.realunit) and UnitExists(self.unit) then
		self.values.vehicle = UnitHasVehicleUI(self.realunit) and 1 or nil
		for _, event in ipairs(updateEvents) do
			handlers[event](self)

		end
		if not self.needAutoUpdate then
			handlers.GROUP_ROSTER_UPDATE(self)
			if self.feedbackFrame then
				self.feedbackFrame:Hide()
				self.feedbackFrame.feedbackText:SetText(nil)
				self.feedbackFrame.feedbackStartTime = nil
			end
		end
	end



end

function handlers:UNIT_COMBAT(...)
	if self.showCombatFeedback and self.feedbackFrame then
		CombatFeedback_OnCombatEvent(self.feedbackFrame, ...)
		self.feedbackFrame:Show()
	end
end

local feedbackUnit = { player = true, target = true }

function IUF:RegsiterCombatFeedback()
	for unit in pairs(feedbackUnit) do
		if type(self.units[unit].db.portrait) == "string" and self.units[unit].db.portrait:find("^return") then
			self.units[unit].showCombatFeedback = self.units[unit].db.combatFeedback
		else
			self.units[unit].showCombatFeedback = nil
		end
		if self.units[unit].feedbackFrame then
			self.units[unit].feedbackFrame:Hide()
			self.units[unit].feedbackFrame.feedbackText:SetText(nil)
			self.units[unit].feedbackFrame.feedbackStartTime = nil
			self.units[unit].feedbackFrame.feedbackFontHeight = self.units[unit].db.combatFeedbackFontSize
		end
	end
	if self.units.player.showCombatFeedback or self.units.target.showCombatFeedback then
		handlers:RegisterEvent("UNIT_COMBAT")
	else
		handlers:UnregisterEvent("UNIT_COMBAT")
	end
end

function handlers:UNIT_PORTRAIT_UPDATE()
	self.values.modelfile = not self.values.modelfile
	for object in pairs(IUF.visibleObject) do
		if object.needAutoUpdate and self.unit and object.unit and UnitIsUnit(self.unit, object.unit) then
			object.values.modelfile = not object.values.modelfile
		end
	end
end

local function getUnitLevel(unit)
	if ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
		return UnitBattlePetLevel(unit);
	end
	return UnitLevel(unit) or -1
end

local unitName, unitRealm

function handlers:UNIT_NAME_UPDATE()
	if IUF.db.skin == "Blizzard" and self.objectType == "party" then
		unitName, unitRealm = UnitName(self.unit)
		if unitName then
			if unitRealm and unitRealm ~= "" then
				self.values.name = unitName.."-"..unitRealm
			else
				self.values.name = unitName
			end
		else
			self.values.name = UNKNOWNOBJECT
		end
	else
		self.values.name = UnitName(self.unit) or UNKNOWNOBJECT
	end
	self.values.level = getUnitLevel(self.unit)
	self.values.attack = UnitCanAttack("player", self.unit)
	self.values.player = UnitIsPlayer(self.unit)
	--LFG시 class보정
	self.values.class=select(2, UnitClass(self.unit)) or "PET"

	if self.values.player then
		self.values.classification = nil
		self.values.elite = nil
--		self.values.class = select(2, UnitClass(self.unit)) or "PET"
		self.values.creature = nil
		self.values.questBoss = nil
	else
		self.values.classification = UnitClassification(self.unit)
		self.values.elite = (self.values.classification or ""):find("elite$") and 1 or nil
		self.values.class = "PET"
		if creatureTypes[UnitCreatureType(self.unit) or ""] then
			self.values.creature = UnitCreatureType(self.unit)
		else
			self.values.creature = nil
		end
		self.values.questBoss = UnitIsQuestBoss(self.unit) and 1 or nil
	end
	if UnitIsQuestBoss(self.unit) then
		self.values.pvp = 3
	elseif UnitIsPVPFreeForAll(self.unit) or UnitIsPVP(self.unit) then
		self.values.pvp = factionGroups[UnitFactionGroup(self.unit) or ""] or nil
	else
		self.values.pvp = nil
	end
	if UnitIsFriend("player", self.unit) then
		if self.values.player then
			self.values.faction = nil
		else
			self.values.faction = "FRIEND"
		end
	elseif UnitIsEnemy("player", self.unit) then
		self.values.faction = "ENEMY"
	elseif self.values.player then
		self.values.faction = nil
	else
		self.values.faction = "NEUTRAL"
	end
end

function handlers:UNIT_HEALTH()
	self.values.health = UnitHealth(self.unit)
	self.values.dead = UnitIsDead(self.unit)
	self.values.ghost = UnitIsGhost(self.unit)
end

function handlers:UNIT_MAXHEALTH()
	self.values.healthmax = UnitHealthMax(self.unit)
end

function handlers:READY_CHECK_CONFIRM(isReady)
	IUF:UpdateReadyCheck(self)
end


if (select(4,GetBuildInfo()) <= 90000) then
function handlers:UNIT_HEALTH_FREQUENT()
	self.values.health = UnitHealth(self.unit)
end
end

function handlers:UNIT_DISPLAYPOWER()
	local alternatePower = false
	local minPower = 0

	local barInfo = GetUnitPowerBarInfo(self.unit);
	if barInfo and barInfo.minPower then
		alternatePower = true
		minPower = barInfo.minPower;
	end

	if alternatePower and not UnitIsPlayer(self.unit) then
		self.values.powertype = "ALTERNATE"
		self.values.powermin = minPower
		self.values.powermax = UnitPowerMax(self.unit, ALTERNATE_POWER_INDEX) - self.values.powermin
		self.values.power = UnitPower(self.unit, ALTERNATE_POWER_INDEX) - self.values.powermin
	else
		self.values.powertype = UnitPowerType(self.unit)
		self.values.powermax = UnitPowerMax(self.unit)
		self.values.power = UnitPower(self.unit)
		if self.values.powermax < self.values.power then
			self.values.powermax = self.values.power
		end
	end
end

function handlers:UNIT_POWER_UPDATE()
	if self.values.powertype == "ALTERNATE" then
		self.values.power = UnitPower(self.unit, ALTERNATE_POWER_INDEX) - (self.values.powermin or 0)
	else
		self.values.power = UnitPower(self.unit)
	end
end

function handlers:UNIT_MAXPOWER()
	local minPower = 0

	local barInfo = GetUnitPowerBarInfo(self.unit);
	if barInfo and barInfo.minPower then
		minPower = barInfo.minPower;
	end

	if self.values.powertype == "ALTERNATE" then
		self.values.powermin = minPower
		self.values.powermax = UnitPowerMax(self.unit, ALTERNATE_POWER_INDEX) - self.values.powermin
	else
		self.values.powermax = UnitPowerMax(self.unit)
	end
end

handlers.UNIT_POWER_FREQUENT = handlers.UNIT_POWER_UPDATE

function handlers:RAID_TARGET_UPDATE()
	self.values.raidtarget = UnitExists(self.unit) and GetRaidTargetIndex(self.unit) or nil
end

function handlers:UNIT_ENTERED_VEHICLE()
	if UnitHasVehicleUI(self.realunit) and self.unit then
		self.values.vehicle = 1
		if IUF.units[self.unit] and IUF.units[self.unit].unit then
			handlers.PLAYER_ENTERING_WORLD(IUF.units[self.unit])
		end
	end
end

function handlers:UNIT_EXITED_VEHICLE()
	self.values.vehicle = nil
	if self.petunit and IUF.units[self.petunit] and IUF.units[self.petunit].unit then
		handlers.PLAYER_ENTERING_WORLD(IUF.units[self.petunit])
	end
end

function handlers:UNIT_PET()
	if self.petunit and IUF.units[self.petunit] and IUF.units[self.petunit].unit then
		handlers.PLAYER_ENTERING_WORLD(IUF.units[self.petunit])
	end
end

function handlers:PLAYER_UPDATE_RESTING()
	if self.objectType == "player" then
		self.values.resting = IsResting()
	else
		self.values.resting = nil
	end
end

function handlers:UNIT_POWER_UPDATE()
	self.values.combo = GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player", self.unit)
end

local endTime, _

function handlers:UNIT_SPELLCAST_START()
	if UnitCastingInfo(self.unit) then
		self.values.castingIsChannel = nil
		self.values.castingName, _, self.values.castingIcon, self.values.castingStartTime, endTime, _, _, self.values.castingIsShield = UnitCastingInfo(self.unit)
		self.values.castingEndTime = endTime
	elseif UnitChannelInfo(self.unit) then
		self.values.castingIsChannel = true
		self.values.castingName, _, self.values.castingIcon, self.values.castingStartTime, endTime, _, self.values.castingIsShield = UnitChannelInfo(self.unit)
		self.values.castingEndTime = endTime
	else
		handlers.UNIT_SPELLCAST_STOP(self)
	end
end

function handlers:UNIT_SPELLCAST_STOP()
	self.values.castingIsChannel, self.values.castingName, self.values.castingRank, self.values.castingIcon, self.values.castingStartTime, self.values.castingIsShield, self.values.castingEndTime = nil
end

function handlers:UNIT_SPELLCAST_INTERRUPTIBLE()
	self.values.castingIsShield = nil
end

function handlers:UNIT_SPELLCAST_NOT_INTERRUPTIBLE()
	self.values.castingIsShield = true
end

function handlers:UNIT_HEAL_PREDICTION()
	if IUF.db.heal.player then
		self.values.heal = UnitGetIncomingHeals(self.unit) or 0
	else
		self.values.heal = (UnitGetIncomingHeals(self.unit) or 0) - (UnitGetIncomingHeals(self.unit, "player") or 0)
	end
end

function handlers:UNIT_THREAT_SITUATION_UPDATE()
	if (UnitThreatSituation(self.unit) or 0) > 1 then
		self.values.aggro = true
	else
		self.values.aggro = nil
	end
end

local raidIndex, raidRank, raidGroup, roleIsTank, roleIsHeal, roleIsDPS

function handlers:GROUP_ROSTER_UPDATE()
	if UnitInRaid(self.realunit) and IsInGroup() and IsInRaid() then
		self.values.role = nil
		raidIndex = UnitInRaid(self.realunit)
		raidRank, raidGroup, _, _, _, _, _, _, _, self.values.looter = select(2, GetRaidRosterInfo(raidIndex))
		if raidRank == 2 then
			self.values.leader = 1
		elseif raidRank == 1 then
			self.values.leader = 2
		else
			self.values.leader = nil
		end
		if self.objectType == "player" or self.objectType == "target" or self.objectType == "focus" then
			self.values.group = raidGroup
		else
			self.values.group = nil
		end
	elseif (self.realunit == "player" or UnitInParty(self.realunit)) and IsInGroup() then
		if self.objectType == "player" or self.objectType == "party" then
			roleIsTank = UnitGroupRolesAssigned(self.realunit)
			if roleIsTank == "TANK" then
				self.values.role = 1
			elseif roleIsTank == "HEALER" then
				self.values.role = 2
			elseif roleIsTank == "DAMAGER" then
				self.values.role = 3
			else
				self.values.role = nil
			end
		else
			self.values.role = nil
		end
		if UnitIsGroupLeader(self.realunit) then
			self.values.leader = 1
			self.values.looter = GetLootMethod() == "master" and 1 or nil
		else
			self.values.leader, self.values.looter = nil
		end
		self.values.group = nil
	else
		self.values.group, self.values.leader, self.values.looter, self.values.role = nil
	end
end

handlers.PARTY_LEADER_CHANGED = handlers.GROUP_ROSTER_UPDATE
handlers.UNIT_LEVEL = handlers.UNIT_NAME_UPDATE
handlers.UNIT_FACTION = handlers.UNIT_NAME_UPDATE
handlers.UNIT_CLASSIFICATION_CHANGED = handlers.UNIT_NAME_UPDATE
handlers.UNIT_MODEL_CHANGED = handlers.UNIT_PORTRAIT_UPDATE
handlers.UNIT_SPELLCAST_DELAYED = handlers.UNIT_SPELLCAST_START
handlers.UNIT_SPELLCAST_CHANNEL_START = handlers.UNIT_SPELLCAST_START
handlers.UNIT_SPELLCAST_CHANNEL_UPDATE = handlers.UNIT_SPELLCAST_START
handlers.UNIT_SPELLCAST_CHANNEL_STOP = handlers.UNIT_SPELLCAST_STOP
handlers.UNIT_POWER_BAR_SHOW = handlers.UNIT_DISPLAYPOWER
handlers.UNIT_POWER_BAR_HIDE = handlers.UNIT_DISPLAYPOWER

local refreshFrame = CreateFrame("Frame")
refreshFrame.object = {}
refreshFrame:Hide()
refreshFrame:SetScript("OnUpdate", function(self, timer)
	self.timer = self.timer + timer
	if self.timer > 0.5 then
		self.timer, self.count = 0, 0
		for object, count in pairs(self.object) do
			if object.unit and UnitExists(object.unit) then
				IUF.handlers.PLAYER_ENTERING_WORLD(object)
				self.object[object] = count - 1
				if self.object[object] > 0 then
					self.count = self.count + 1
				else
					self.object[object] = nil
				end
			else
				self.object[object] = nil
			end
		end
		if self.count <= 0 then
			self:Hide()
		end
	end
end)

function IUF:RefreshObject(object)
	if not object.needAutoUpdate then
		refreshFrame.object[object] = 2
		refreshFrame.timer = 0
		refreshFrame:Show()
	end
end