
local module = {}
local moduleName = "Cooldowns"
MikSBT[moduleName] = module

local MSBTProfiles = MikSBT.Profiles
local MSBTTriggers = MikSBT.Triggers

local string_gsub = string.gsub
local string_find = string.find
local string_format = string.format
local string_match = string.match
local GetItemInfo = C_Item.GetItemInfo

local EraseTable = MikSBT.EraseTable
local GetSkillName = MikSBT.GetSkillName
local GetSpellCooldown = MikSBT.GetSpellCooldown
local GetSpellInfo = MikSBT.GetSpellInfo
local GetSpellTexture = MikSBT.GetSpellTexture
local IsRestrictedContext = MikSBT.IsRestrictedContext
local Print = MikSBT.Print
local DisplayEvent = MikSBT.Animations.DisplayEvent
local HandleCooldowns = MSBTTriggers.HandleCooldowns

local MIN_COOLDOWN_UPDATE_DELAY = 0.1
local MAX_COOLDOWN_UPDATE_DELAY = 1

local SPELLID_COLD_SNAP		= 11958
local SPELLID_MIND_FREEZE	= 47528
local SPELLID_PREPARATION	= 14185
local SPELLID_READINESS		= 23989

local RUNE_COOLDOWN = 10

local _

local eventFrame = CreateFrame("Frame")

local playerClass

local activeCooldowns = {player={}, pet={}, item={}}
local delayedCooldowns = {player={}, pet={}, item={}}
local resetAbilities = {}
local runeCooldownAbilities = {}
local lastCooldownIDs = {}
local watchItemIDs = {}

local updateDelay = MIN_COOLDOWN_UPDATE_DELAY
local lastUpdate = 0

local itemCooldownsEnabled = true
local playerCooldownsEnabled = false
local petCooldownsEnabled = false
local cooldownsRestricted
local cooldownsDisabledNoticeShown
local PLAYER_COOLDOWNS_SUPPORTED = false
local PET_COOLDOWNS_SUPPORTED = false

local function GetCooldownTexture(cooldownType, cooldownID)
	if cooldownType == "item" then
		local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(cooldownID)
		return itemTexture
	else
		local iconID = GetSpellTexture(cooldownID)
		if iconID then
			return iconID
		else
			return GetSpellInfo(cooldownID)
		end
	end
end

local function NormalizeNumber(value)
	local ok, result = pcall(function()
		return value + 0
	end)
	if ok and type(result) == "number" then
		return result
	end
	return nil
end

local function OnSpellCast(unitID, spellID)
	local spellName = GetSpellInfo(spellID) or UNKNOWN
	local cooldownExclusions = MSBTProfiles.currentProfile.cooldownExclusions
	if cooldownExclusions[spellName] or cooldownExclusions[spellID] then
		return
	end

	if resetAbilities[spellID] and unitID == "player" then
		for spellID, remainingDuration in pairs(activeCooldowns[unitID]) do
			local startTime, duration = GetSpellCooldown(spellID)
			duration = NormalizeNumber(duration)
			if duration and duration <= 1.5 and remainingDuration > 1.5 then
				activeCooldowns[unitID][spellID] = nil
			end

			updateDelay = MIN_COOLDOWN_UPDATE_DELAY
		end
	end

	lastCooldownIDs[unitID] = spellID
end

local function OnItemUse(itemID)
	local itemName = GetItemInfo(itemID)
	local cooldownExclusions = MSBTProfiles.currentProfile.cooldownExclusions
	if cooldownExclusions[itemName] or cooldownExclusions[itemID] then
		return
	end

	watchItemIDs[itemID] = GetTime()

	updateDelay = MIN_COOLDOWN_UPDATE_DELAY

	if not eventFrame:IsVisible() then
		eventFrame:Show()
	end
end

local function OnUpdateCooldown(cooldownType, cooldownFunc)
	if not delayedCooldowns[cooldownType] or not activeCooldowns[cooldownType] then
		return
	end

	for cooldownID in pairs(delayedCooldowns[cooldownType]) do
		local startTime, duration = cooldownFunc(cooldownID)
		startTime = NormalizeNumber(startTime)
		duration = NormalizeNumber(duration)
		if startTime and duration then
			local cooldownName = GetSpellInfo(cooldownID)
			local ignoreCooldownThreshold = MSBTProfiles.currentProfile.ignoreCooldownThreshold
			if duration >= MSBTProfiles.currentProfile.cooldownThreshold or ignoreCooldownThreshold[cooldownName] or ignoreCooldownThreshold[cooldownID] then
				activeCooldowns[cooldownType][cooldownID] = duration

				updateDelay = MIN_COOLDOWN_UPDATE_DELAY

				if not eventFrame:IsVisible() then
					eventFrame:Show()
				end
			end

			delayedCooldowns[cooldownType][cooldownID] = nil
		end
	end

	local cooldownID = lastCooldownIDs[cooldownType]
	if cooldownID then
		local startTime, duration = cooldownFunc(cooldownID)
		startTime = NormalizeNumber(startTime)
		duration = NormalizeNumber(duration)
		if startTime and duration then
			if playerClass == "DEATHKNIGHT" and duration == RUNE_COOLDOWN and cooldownType == "player" and not runeCooldownAbilities[cooldownID] then
				duration = -1
			end

			local cooldownName = GetSpellInfo(cooldownID)
			local ignoreCooldownThreshold = MSBTProfiles.currentProfile.ignoreCooldownThreshold
			if duration >= MSBTProfiles.currentProfile.cooldownThreshold or ignoreCooldownThreshold[cooldownName] or ignoreCooldownThreshold[cooldownID] then
				activeCooldowns[cooldownType][cooldownID] = duration

				updateDelay = MIN_COOLDOWN_UPDATE_DELAY

				if not eventFrame:IsVisible() then
					eventFrame:Show()
				end
			end

		else
			delayedCooldowns[cooldownType][cooldownID] = true
		end

		lastCooldownIDs[cooldownType] = nil
	end
end

local function OnUpdate(frame, elapsed)

	lastUpdate = lastUpdate + elapsed

	if lastUpdate >= updateDelay then

		updateDelay = MAX_COOLDOWN_UPDATE_DELAY

		local currentTime = GetTime()
		for cooldownID, usedTime in pairs(watchItemIDs) do
			if currentTime >= (usedTime + 1) then
				lastCooldownIDs["item"] = cooldownID
				OnUpdateCooldown("item", C_Container.GetItemCooldown)
				watchItemIDs[cooldownID] = nil
				break
			end
		end

		local currentTime = GetTime()
		for cooldownType, cooldowns in pairs(activeCooldowns) do
			local cooldownFunc = (cooldownType == "item") and C_Container.GetItemCooldown or GetSpellCooldown
			local infoFunc = (cooldownType == "item") and GetItemInfo or GetSpellInfo
			for cooldownID, remainingDuration in pairs(cooldowns) do
				local startTime, duration = cooldownFunc(cooldownID)
				startTime = NormalizeNumber(startTime)
				duration = NormalizeNumber(duration)
				if startTime and duration then
					local cooldownRemaining = startTime + duration - currentTime

					if cooldownType == "pet" then
						cooldownRemaining = remainingDuration - lastUpdate
					end

					if cooldownRemaining <= 0 then
						local cooldownName = infoFunc(cooldownID) or UNKNOWN
						local texture = GetCooldownTexture(cooldownType, cooldownID)
						HandleCooldowns(cooldownType, cooldownID, cooldownName, texture)

						local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_COOLDOWN
						if cooldownType == "pet" then
							eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_PET_COOLDOWN
						elseif cooldownType == "item" then
							eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_ITEM_COOLDOWN
						end
						if eventSettings and not eventSettings.disabled then
							local message = eventSettings.message
							local formattedSkillName = string_format("|cFF%02x%02x%02x%s|r", eventSettings.skillColorR * 255, eventSettings.skillColorG * 255, eventSettings.skillColorB * 255, string_gsub(cooldownName, "%(.+%)%(%)$", ""))
							message = string_gsub(message, "%%e", formattedSkillName)
							DisplayEvent(eventSettings, message, texture)
						end

						cooldowns[cooldownID] = nil

					else
						cooldowns[cooldownID] = cooldownRemaining
						if cooldownRemaining < updateDelay then
							updateDelay = cooldownRemaining
						end
					end

				else
					local cooldownRemaining = remainingDuration - lastUpdate
					if cooldownRemaining <= 0 then
						local cooldownName = infoFunc(cooldownID) or UNKNOWN
						local texture = GetCooldownTexture(cooldownType, cooldownID)
						HandleCooldowns(cooldownType, cooldownID, cooldownName, texture)

						local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_COOLDOWN
						if cooldownType == "pet" then
							eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_PET_COOLDOWN
						elseif cooldownType == "item" then
							eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_ITEM_COOLDOWN
						end
						if eventSettings and not eventSettings.disabled then
							local message = eventSettings.message
							local formattedSkillName = string_format("|cFF%02x%02x%02x%s|r", eventSettings.skillColorR * 255, eventSettings.skillColorG * 255, eventSettings.skillColorB * 255, string_gsub(cooldownName, "%(.+%)%(%)$", ""))
							message = string_gsub(message, "%%e", formattedSkillName)
							DisplayEvent(eventSettings, message, texture)
						end

						cooldowns[cooldownID] = nil
					else
						cooldowns[cooldownID] = cooldownRemaining
						if cooldownRemaining < updateDelay then
							updateDelay = cooldownRemaining
						end
					end
				end
			end
		end

		if updateDelay < MIN_COOLDOWN_UPDATE_DELAY then
			updateDelay = MIN_COOLDOWN_UPDATE_DELAY
		end

		local allInactive = true
		for cooldownType, cooldowns in pairs(activeCooldowns) do
			if next(cooldowns) then
				allInactive = false
			end
		end
		if allInactive and not next(watchItemIDs) then
			eventFrame:Hide()
		end

		lastUpdate = 0
	end
end

function eventFrame:UNIT_SPELLCAST_SUCCEEDED(unitID, ...)
	if not playerCooldownsEnabled then
		return
	end
	if unitID ~= "player" then
		return
	end

	-- Retail/classic variants may pass spellID in different arg positions.
	local skillID
	for index = select("#", ...), 1, -1 do
		local value = select(index, ...)
		if type(value) == "number" then
			skillID = value
			break
		end
	end
	if not skillID then
		return
	end

	OnSpellCast("player", skillID)
	OnUpdateCooldown("player", GetSpellCooldown)
end

function eventFrame:COMBAT_LOG_EVENT_UNFILTERED()
	if not PET_COOLDOWNS_SUPPORTED then
		return
	end
	eventFrame:CombatLogEvent(CombatLogGetCurrentEventInfo())
end

function eventFrame:CombatLogEvent(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, recipientGUID, recipientName, recipientFlags, recipientRaidFlags, skillID)
	if not petCooldownsEnabled then
		return
	end

	if event ~= "SPELL_CAST_SUCCESS" then
		return
	end

	if sourceGUID == UnitGUID("pet") then
		OnSpellCast("pet", skillID)
	end
end

function eventFrame:SPELL_UPDATE_COOLDOWN()
	if not playerCooldownsEnabled then
		return
	end
	OnUpdateCooldown("player", GetSpellCooldown)
end

function eventFrame:PET_BAR_UPDATE_COOLDOWN()
	if not petCooldownsEnabled then
		return
	end
	OnUpdateCooldown("pet", GetSpellCooldown)
end

local function UpdateRestrictionState()
	local restricted = IsRestrictedContext()

	if cooldownsRestricted == nil then
		cooldownsRestricted = restricted
		if restricted then
			Print("Cooldown alerts are temporarily disabled by Blizzard restrictions in this combat context.")
		end
		return
	end

	if restricted and not cooldownsRestricted then
		cooldownsRestricted = true
		Print("Cooldown alerts are temporarily disabled by Blizzard restrictions in this combat context.")
	elseif not restricted and cooldownsRestricted then
		cooldownsRestricted = false
		Print("Cooldown alerts have been re-enabled.")
	end
end

local function UpdateRegisteredEvents()
	local doEnable = false
	if PLAYER_COOLDOWNS_SUPPORTED and (not MSBTProfiles.currentProfile.events.NOTIFICATION_COOLDOWN.disabled or MSBTTriggers.categorizedTriggers["SKILL_COOLDOWN"]) then
		doEnable = true
	end
	playerCooldownsEnabled = doEnable

	local doEnable = false
	if PET_COOLDOWNS_SUPPORTED and (not MSBTProfiles.currentProfile.events.NOTIFICATION_PET_COOLDOWN.disabled or MSBTTriggers.categorizedTriggers["PET_COOLDOWN"]) then
		doEnable = true
	end
	petCooldownsEnabled = doEnable

	local doEnable = false
	if not MSBTProfiles.currentProfile.events.NOTIFICATION_ITEM_COOLDOWN.disabled or MSBTTriggers.categorizedTriggers["ITEM_COOLDOWN"] then
		doEnable = true
	end
	itemCooldownsEnabled = doEnable

	for cooldownType, cooldowns in pairs(activeCooldowns) do EraseTable(cooldowns) end
	for cooldownType, cooldowns in pairs(delayedCooldowns) do EraseTable(cooldowns) end
	EraseTable(lastCooldownIDs)
	EraseTable(watchItemIDs)
	eventFrame:Hide()
end

local function Enable()
	UpdateRegisteredEvents()
end

local function Disable()
	eventFrame:Hide()

	for cooldownType, cooldowns in pairs(activeCooldowns) do EraseTable(cooldowns) end
	for cooldownType, cooldowns in pairs(delayedCooldowns) do EraseTable(cooldowns) end
	EraseTable(watchItemIDs)
end

function eventFrame:PLAYER_REGEN_DISABLED()
	UpdateRegisteredEvents()
end

function eventFrame:PLAYER_REGEN_ENABLED()
	UpdateRegisteredEvents()
end

function eventFrame:PLAYER_ENTERING_WORLD()
	UpdateRegisteredEvents()
end

function eventFrame:ZONE_CHANGED_NEW_AREA()
	UpdateRegisteredEvents()
end

function eventFrame:CHALLENGE_MODE_START()
	UpdateRegisteredEvents()
end

function eventFrame:CHALLENGE_MODE_COMPLETED()
	UpdateRegisteredEvents()
end

local function UseActionHook(slot)
	if not itemCooldownsEnabled then
		return
	end

	local actionType, itemID = GetActionInfo(slot)
	if actionType == "item" then
		OnItemUse(itemID)
	end
end

local function UseInventoryItemHook(slot)
	if not itemCooldownsEnabled then
		return
	end

	local itemID = GetInventoryItemID("player", slot)
	if itemID then
		OnItemUse(itemID)
	end
end

local function UseContainerItemHook(bag, slot)
	if not itemCooldownsEnabled then
		return
	end

	local itemID = C_Container.GetContainerItemID(bag, slot)
	if itemID then
		OnItemUse(itemID)
	end
end

local function UseItemByNameHook(itemName)
	if not itemCooldownsEnabled or not itemName then
		return
	end

	local _, itemLink = GetItemInfo(itemName)
	local itemID
	if itemLink then
		itemID = string_match(itemLink, "item:(%d+)")
	end
	if itemID then
		OnItemUse(itemID)
	end
end

eventFrame:Hide()
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)
eventFrame:SetScript("OnUpdate", OnUpdate)

eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")

_, playerClass = UnitClass("player")

hooksecurefunc("UseAction", UseActionHook)
hooksecurefunc("UseInventoryItem", UseInventoryItemHook)
hooksecurefunc(C_Container, "UseContainerItem", UseContainerItemHook)
hooksecurefunc(C_Item, "UseItemByName", UseItemByNameHook)

resetAbilities[SPELLID_COLD_SNAP] = true
resetAbilities[SPELLID_PREPARATION] = true
resetAbilities[SPELLID_READINESS] = true

runeCooldownAbilities[SPELLID_MIND_FREEZE] = true

module.Enable					= Enable
module.Disable					= Disable
module.UpdateRegisteredEvents	= UpdateRegisteredEvents

