local module = {}
local moduleName = "Cooldowns"
MikSBT[moduleName] = module

local MSBTProfiles = MikSBT.Profiles
local ItemCooldownTracker = MikSBT.Components.ItemCooldownTracker
local API = MikSBT.API

local GetItemInfo = C_Item.GetItemInfo
local DisplayEvent = MikSBT.Animations.DisplayEvent

local eventFrame = CreateFrame("Frame")
local isEnabled = false
local playerCooldowns = {}
local spellElapsed = 0
local UPDATE_INTERVAL = 0.1
local SPELL_START_WINDOW = 2
local COOLDOWN_CONFIRMATION_GRACE = 30
local UNCONFIRMED_SPELL_TIMEOUT = 3600
local GLOBAL_COOLDOWN_SPELL = 61304

local function NormalizeNumber(value)
	local success, result = pcall(function()
		return value + 0
	end)
	if success and type(result) == "number" then
		return result
	end
	return nil
end

local itemTracker = ItemCooldownTracker:New({
	getProfile = function()
		return MSBTProfiles.currentProfile
	end,
	getTime = GetTime,
	getItemInfo = GetItemInfo,
	getItemCooldown = C_Container.GetItemCooldown,
	normalizeNumber = NormalizeNumber,
	display = DisplayEvent,
	unknown = UNKNOWN,
	watchDelay = 1,
	updateInterval = UPDATE_INTERVAL,
})

local function AbilityReadySettings()
	if not isEnabled then return end
	local settings = MSBTProfiles.currentProfile.events.NOTIFICATION_ABILITY_READY
	if settings and not settings.disabled then return settings end
end

local function IsKnownPlayerAbility(spellID)
	local isKnown = C_SpellBook and (C_SpellBook.IsSpellKnownOrInSpellBook
		or C_SpellBook.IsSpellKnown) or IsPlayerSpell or IsSpellKnown
	if type(isKnown) ~= "function" then return false end
	local ok, known = pcall(isKnown, spellID)
	return ok and API.RestrictedValue:Boolean(known) == true
end

local function RecordAbilityCast(unit, spellID)
	if not AbilityReadySettings() or not API.RestrictedValue:Equals(unit, "player") then
		return
	end
	spellID = API.RestrictedValue:Number(spellID)
	if not spellID or spellID <= 0 or not IsKnownPlayerAbility(spellID) then return end
	if not playerCooldowns[spellID] then
		playerCooldowns[spellID] = { deadline = GetTime() + SPELL_START_WINDOW }
	end
	eventFrame:Show()
end

local function DisplayAbilityReady(settings, spellID)
	local spell = API.Spells:GetInfo(spellID)
	if not spell then return end
	local message = settings.message:gsub("%%s", function() return spell.name end)
	DisplayEvent(settings, message, spell.iconID)
end

local function UpdatePlayerCooldowns(elapsed, fromCooldownEvent)
	if not next(playerCooldowns) then return false end
	local settings = AbilityReadySettings()
	if not settings then
		playerCooldowns = {}
		spellElapsed = 0
		return false
	end
	spellElapsed = spellElapsed + elapsed
	if not fromCooldownEvent and spellElapsed < UPDATE_INTERVAL then return true end
	spellElapsed = 0

	local now = GetTime()
	local threshold = MSBTProfiles.currentProfile.cooldownThreshold or 5
	local gcd = API.Cooldowns:GetSpell(GLOBAL_COOLDOWN_SPELL)
	for spellID, tracked in pairs(playerCooldowns) do
		local cooldown = API.Cooldowns:GetSpellStatus(spellID)
		if cooldown and cooldown.isEnabled == false then
			if not tracked.activeSince and not tracked.held then
				tracked.held = true
				tracked.deadline = now + UNCONFIRMED_SPELL_TIMEOUT
			end
		elseif cooldown then
			local duration = cooldown.duration
			local isGlobal = (fromCooldownEvent and cooldown.isOnGCD == true)
				or (gcd and gcd.duration > 0 and duration == gcd.duration
					and cooldown.startTime == gcd.startTime)
			local ready = duration == 0
				or (fromCooldownEvent and cooldown.isActive == false)
			if tracked.activeSince and ready and not isGlobal then
				playerCooldowns[spellID] = nil
				if tracked.qualifies or (tracked.qualifies == nil
					and now - tracked.activeSince >= threshold) then
					DisplayAbilityReady(settings, spellID)
				end
			elseif not isGlobal and duration and duration > 0
				and cooldown.startTime + duration > now
				and (tracked.activeSince or duration >= threshold) then
				tracked.activeSince = tracked.activeSince or now
				tracked.qualifies = tracked.qualifies or duration >= threshold
				tracked.deadline = cooldown.startTime + duration
					+ COOLDOWN_CONFIRMATION_GRACE
			elseif fromCooldownEvent and duration == nil and cooldown.isActive
				and cooldown.isOnGCD == false and not tracked.activeSince then
				tracked.activeSince = now
				tracked.deadline = now + UNCONFIRMED_SPELL_TIMEOUT
			end
		end
		-- An unreadable cooldown never counts as ready.
		if now > tracked.deadline then playerCooldowns[spellID] = nil end
	end
	return next(playerCooldowns) ~= nil
end

local function IsItemTrackingEnabled()
	local profile = MSBTProfiles.currentProfile
	local settings = profile.events.NOTIFICATION_ITEM_COOLDOWN
	return (settings and not settings.disabled)
end

local function UpdateRegisteredEvents()
	itemTracker:SetEnabled(isEnabled and IsItemTrackingEnabled())
	if next(itemTracker.watchedItems) or next(itemTracker.activeCooldowns)
		or next(playerCooldowns) then
		eventFrame:Show()
	else
		eventFrame:Hide()
	end
end

local function RecordItemUse(itemID)
	if itemTracker:RecordUse(itemID) then
		eventFrame:Show()
	end
end

local function UseActionHook(slot)
	local actionType, itemID = GetActionInfo(slot)
	if actionType == "item" then
		RecordItemUse(itemID)
	end
end

local function UseInventoryItemHook(slot)
	local itemID = GetInventoryItemID("player", slot)
	if itemID then
		RecordItemUse(itemID)
	end
end

local function UseContainerItemHook(bag, slot)
	local itemID = C_Container.GetContainerItemID(bag, slot)
	if itemID then
		RecordItemUse(itemID)
	end
end

local function UseItemByNameHook(itemName)
	if not itemName then
		return
	end
	local _, itemLink = GetItemInfo(itemName)
	local itemID = itemLink and string.match(itemLink, "item:(%d+)")
	if itemID then
		RecordItemUse(itemID)
	end
end

local function Enable()
	isEnabled = true
	UpdateRegisteredEvents()
end

local function Disable()
	isEnabled = false
	itemTracker:SetEnabled(false)
	playerCooldowns = {}
	spellElapsed = 0
	eventFrame:Hide()
end

local function OnUpdate(_, elapsed)
	local watchingItems = itemTracker:Tick(elapsed)
	local watchingSpells = UpdatePlayerCooldowns(elapsed)
	if not watchingItems and not watchingSpells then
		eventFrame:Hide()
	end
end

local function OnEvent(_, event, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spellID = ...
		RecordAbilityCast(unit, spellID)
		return
	end
	if event == "SPELL_UPDATE_COOLDOWN" then
		if next(playerCooldowns) and not UpdatePlayerCooldowns(0, true) then
			UpdateRegisteredEvents()
		end
		return
	end
	UpdateRegisteredEvents()
end

eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:SetScript("OnUpdate", OnUpdate)

eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
if API and API.Cooldowns and API.Spells then
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
end

hooksecurefunc("UseAction", UseActionHook)
hooksecurefunc("UseInventoryItem", UseInventoryItemHook)
hooksecurefunc(C_Container, "UseContainerItem", UseContainerItemHook)
hooksecurefunc(C_Item, "UseItemByName", UseItemByNameHook)

module.Enable = Enable
module.Disable = Disable
module.UpdateRegisteredEvents = UpdateRegisteredEvents
