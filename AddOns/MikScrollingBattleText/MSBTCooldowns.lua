local module = {}
local moduleName = "Cooldowns"
MikSBT[moduleName] = module

local MSBTProfiles = MikSBT.Profiles
local MSBTTriggers = MikSBT.Triggers
local ItemCooldownTracker = MikSBT.Components.ItemCooldownTracker

local GetItemInfo = C_Item.GetItemInfo
local DisplayEvent = MikSBT.Animations.DisplayEvent
local HandleCooldowns = MSBTTriggers.HandleCooldowns or function() end

local eventFrame = CreateFrame("Frame")

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
	handleCooldown = HandleCooldowns,
	unknown = UNKNOWN,
	watchDelay = 1,
	updateInterval = 0.1,
})

local function IsItemTrackingEnabled()
	local profile = MSBTProfiles.currentProfile
	local settings = profile.events.NOTIFICATION_ITEM_COOLDOWN
	return (settings and not settings.disabled)
		or MSBTTriggers.categorizedTriggers["ITEM_COOLDOWN"]
end

local function UpdateRegisteredEvents()
	itemTracker:SetEnabled(IsItemTrackingEnabled())
	itemTracker:Reset()
	eventFrame:Hide()
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
	UpdateRegisteredEvents()
end

local function Disable()
	itemTracker:Reset()
	eventFrame:Hide()
end

local function OnUpdate(_, elapsed)
	if not itemTracker:Tick(elapsed) then
		eventFrame:Hide()
	end
end

local function OnEvent()
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

hooksecurefunc("UseAction", UseActionHook)
hooksecurefunc("UseInventoryItem", UseInventoryItemHook)
hooksecurefunc(C_Container, "UseContainerItem", UseContainerItemHook)
hooksecurefunc(C_Item, "UseItemByName", UseItemByNameHook)

module.Enable = Enable
module.Disable = Disable
module.UpdateRegisteredEvents = UpdateRegisteredEvents
