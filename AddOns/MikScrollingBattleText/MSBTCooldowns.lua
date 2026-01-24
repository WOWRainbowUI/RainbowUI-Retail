--- START OF FILE MSBTCooldowns.lua ---

-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Cooldowns
-- Author: Mikord
-- Restoration: WoW 12.0.1 (Midnight) - The "Learning Cache" (Combat Fix)
-------------------------------------------------------------------------------

local module = {}
local moduleName = "Cooldowns"
MikSBT[moduleName] = module

-- [[ DEBUG SETTINGS ]]
local DEBUG_MODE = false

-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------
local MSBTProfiles = MikSBT.Profiles
local MSBTTriggers = MikSBT.Triggers

local string_gsub = string.gsub
local string_format = string.format
local string_match = string.match
local GetItemInfo = C_Item.GetItemInfo
local EraseTable = MikSBT.EraseTable
local GetSpellTexture = MikSBT.GetSpellTexture
local DisplayEvent = MikSBT.Animations.DisplayEvent
local HandleCooldowns = MSBTTriggers.HandleCooldowns
local pcall = pcall

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local MIN_COOLDOWN_UPDATE_DELAY = 0.1
local MAX_COOLDOWN_UPDATE_DELAY = 0.5 
local GCD_DURATION = 1.6 

-- Fallback DB (Pre-seeded with your requests)
local MANUAL_COOLDOWNS = {
    [57994] = 30,  -- Wind Shear
    [192058] = 45, -- Capacitor Totem
    [51514] = 12,  -- Hex
    [378081] = 60, -- Nature's Swiftness
}

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
local activeCooldowns = {player={}, pet={}, item={}}
local pendingSpells = {} 
local watchItemIDs = {}
local spellIDCache = {} 
-- The Learning Cache: Stores the Max Duration of spells seen Out of Combat
-- [SpellID] = Duration (e.g., [61295] = 6)
local durationCache = {} 
local updateDelay = MIN_COOLDOWN_UPDATE_DELAY
local lastUpdate = 0
local itemCooldownsEnabled = true

-------------------------------------------------------------------------------
-- 12.0.1 API Helpers
-------------------------------------------------------------------------------
local function DebugPrint(...)
    if DEBUG_MODE then print("|cff00ffff[MSBT]|r", ...) end
end

-- print("|cff00ffff[MSBT]|r Cooldowns 12.0.1: Learning Cache Active")

local function IsSecret(value)
    if issecretvalue then return issecretvalue(value) end
    return false
end

local function GetSpellNameSafe(identifier)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(identifier)
        if info and info.name then return info.name end
    end
    if _G.GetSpellInfo then return _G.GetSpellInfo(identifier) end
    return tostring(identifier)
end

local function ResolveSpellID(spellName)
    if type(spellName) == "number" then return spellName end
    if spellIDCache[spellName] then return spellIDCache[spellName] end

    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellName)
        if info and info.spellID then
            spellIDCache[spellName] = info.spellID
            return info.spellID
        end
    end
    
    local link
    if C_Spell and C_Spell.GetSpellLink then link = C_Spell.GetSpellLink(spellName)
    elseif _G.GetSpellLink then link = _G.GetSpellLink(spellName) end
    
    if link then
        local id = string_match(link, "spell:(%d+)")
        if id then
            spellIDCache[spellName] = tonumber(id)
            return tonumber(id)
        end
    end

    return nil
end

local function GetSpellCooldownSafe(identifier)
    if not identifier then return 0, 0, 0 end
    
    if type(identifier) == "string" and _G.GetSpellCooldown then
        local start, duration, enabled = _G.GetSpellCooldown(identifier)
        if start and duration and duration > GCD_DURATION then 
            return start, duration, enabled 
        end
    end

    local spellID = ResolveSpellID(identifier)
    if spellID and C_Spell and C_Spell.GetSpellCooldown then
        local info = C_Spell.GetSpellCooldown(spellID)
        if info then
            if IsSecret(info.startTime) or IsSecret(info.duration) then return 0, 0, 0 end
            local enabled = (info.isEnabled == true) and 1 or 0
            if info.duration and info.duration > GCD_DURATION then
                return info.startTime, info.duration, enabled
            end
        end
    end

    return 0, 0, 0
end

local function GetSpellChargesSafe(identifier)
    local spellID = ResolveSpellID(identifier)
    if not spellID then return nil end

    if C_Spell and C_Spell.GetSpellCharges then
        local info = C_Spell.GetSpellCharges(spellID)
        if info then
             if IsSecret(info.cooldownStartTime) or IsSecret(info.cooldownDuration) then return nil end
             return info.currentCharges, info.maxCharges, info.cooldownStartTime, info.cooldownDuration
        end
    end
    if _G.GetSpellCharges then return _G.GetSpellCharges(spellID) end
    return nil
end

local function GetCooldownTexture(cooldownType, cooldownID)
    if cooldownType == "item" then
        local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(cooldownID)
        return itemTexture
    else
        local iconID = GetSpellTexture(cooldownID)
        if iconID then return iconID end
        local name = GetSpellNameSafe(cooldownID)
        return GetSpellTexture(name)
    end
end

local function FireNotification(cooldownType, cooldownID, infoFunc)
    local cooldownName = infoFunc(cooldownID) or "Unknown"
    local texture = GetCooldownTexture(cooldownType, cooldownID)
    
    HandleCooldowns(cooldownType, cooldownID, cooldownName, texture)

    local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_COOLDOWN
    if cooldownType == "pet" then eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_PET_COOLDOWN
    elseif cooldownType == "item" then eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_ITEM_COOLDOWN
    end

    if eventSettings and not eventSettings.disabled then
        local message = eventSettings.message
        local formattedSkillName = string_format("|cFF%02x%02x%02x%s|r", eventSettings.skillColorR * 255, eventSettings.skillColorG * 255, eventSettings.skillColorB * 255, string_gsub(cooldownName, "%(.+%)%(%)$", ""))
        message = string_gsub(message, "%%e", formattedSkillName)
        DisplayEvent(eventSettings, message, texture)
    end
    DebugPrint("Notification Fired:", cooldownName)
end

-------------------------------------------------------------------------------
-- Logic
-------------------------------------------------------------------------------

local function TrackActiveCooldown(unitID, spellID, duration, startTime, isManual)
    local cooldownName = GetSpellNameSafe(spellID)
    local ignoreThreshold = MSBTProfiles.currentProfile.ignoreCooldownThreshold
    local threshold = MSBTProfiles.currentProfile.cooldownThreshold or 3

    if duration <= GCD_DURATION and not ignoreThreshold[cooldownName] and not ignoreThreshold[spellID] then
        return false
    end
    
    -- CACHE THE DURATION (The Learning Phase)
    -- If we see a valid duration, save it. This allows us to use it later in combat when the API fails.
    if duration > GCD_DURATION and type(spellID) == "number" then
        if not durationCache[spellID] then
            DebugPrint("Learned Cooldown:", cooldownName, duration.."s")
        end
        durationCache[spellID] = duration
    end
    
    local currentTime = GetTime()
    local endTime = startTime + duration
    
    if activeCooldowns[unitID][spellID] then
        local oldEnd = activeCooldowns[unitID][spellID].endTime
        if math.abs(oldEnd - endTime) < 0.5 then return true end
        if endTime < oldEnd and duration > GCD_DURATION then return true end
    end

    if duration >= threshold or ignoreThreshold[cooldownName] or ignoreThreshold[spellID] then
        activeCooldowns[unitID][spellID] = {
            endTime = endTime,
            duration = duration,
            added = currentTime,
            isManual = isManual
        }
        updateDelay = MIN_COOLDOWN_UPDATE_DELAY
        if not eventFrame:IsVisible() then eventFrame:Show() end
        DebugPrint("Tracking:", cooldownName, duration.."s", isManual and "(Manual/Cache)" or "")
        return true
    end
    return false
end

-- ACTION BAR SCANNER (Populates Cache on Login)
local function ScanActionBars()
    DebugPrint("Scanning Action Bars (Cache Learning)...")
    for i = 1, 120 do
        local type, id = GetActionInfo(i)
        if type == "spell" or type == "macro" then
            local start, duration, enable, modRate = GetActionCooldown(i)
            
            -- Track if active
            if start and duration > GCD_DURATION and enable == 1 then
                local spellID = (type == "spell") and id or ResolveSpellID(GetActionText(i))
                if spellID then
                    TrackActiveCooldown("player", spellID, duration, start)
                end
            end
            
            -- Learn (even if not on CD, we might be able to get info via C_SpellBook later if we expanded logic,
            -- but for now we learn from active CDs or just let them happen naturally)
        end
    end
end

local function ScanAllCooldowns()
    ScanActionBars()
    
    local function scanInv()
        for i = 1, 19 do
            local start, duration, enable = GetInventoryItemCooldown("player", i)
            if start and duration > GCD_DURATION and enable == 1 then
                local itemID = GetInventoryItemID("player", i)
                if itemID then TrackActiveCooldown("item", itemID, duration, start) end
            end
        end
    end
    pcall(scanInv)
end

local function OnSpellCast(unitID, spellID)
    local spellName = GetSpellNameSafe(spellID)
    local cooldownExclusions = MSBTProfiles.currentProfile.cooldownExclusions
    if cooldownExclusions[spellName] or cooldownExclusions[spellID] then return end

    DebugPrint("Cast:", spellName, "("..spellID..")")

    local startTime, duration, enabled = GetSpellCooldownSafe(spellID)
    
    -- Fallbacks
    if (not duration or duration <= GCD_DURATION) and spellName ~= "Unknown" then
        local st2, dur2, en2 = GetSpellCooldownSafe(spellName)
        if dur2 and dur2 > GCD_DURATION then
            startTime, duration, enabled = st2, dur2, en2
            spellID = spellName 
            DebugPrint(" -> Found via String Name")
        end
    end

    if (not duration or duration <= GCD_DURATION) then
        local current, max, chargeStart, chargeDur = GetSpellChargesSafe(spellID)
        if not chargeDur and spellName ~= "Unknown" then
             current, max, chargeStart, chargeDur = GetSpellChargesSafe(spellName)
             if chargeDur then spellID = spellName end
        end
        if chargeDur and chargeDur > GCD_DURATION and current < max then
            startTime = chargeStart
            duration = chargeDur
            enabled = 1
            DebugPrint(" -> Found Charge CD:", duration)
        end
    end

    -- THE CACHE CHECK (Combat Fix)
    -- If API failed (likely due to Combat Secret), check if we know this spell from before.
    if (not duration or duration <= GCD_DURATION) then
        local cachedDur = nil
        
        -- Check Manual DB
        if MANUAL_COOLDOWNS[spellID] then cachedDur = MANUAL_COOLDOWNS[spellID] end
        
        -- Check Learned Cache
        if not cachedDur and durationCache[spellID] then 
            cachedDur = durationCache[spellID] 
        end
        
        -- Check Resolved ID Cache
        if not cachedDur then
            local rid = ResolveSpellID(spellName)
            if rid and durationCache[rid] then cachedDur = durationCache[rid] end
        end

        if cachedDur then
            TrackActiveCooldown(unitID, spellID, cachedDur, GetTime(), true) -- true = Manual/Blind
            return
        end
    end

    if enabled == 1 and duration and duration > GCD_DURATION then
        TrackActiveCooldown(unitID, spellID, duration, startTime)
    else
        pendingSpells[spellID] = { 
            unit = unitID,
            id = spellID, 
            name = spellName,
            time = GetTime() 
        }
        if not eventFrame:IsVisible() then eventFrame:Show() end
    end
end

local function OnUpdate(frame, elapsed)
    lastUpdate = lastUpdate + elapsed

    if lastUpdate >= updateDelay then
        updateDelay = MAX_COOLDOWN_UPDATE_DELAY
        local currentTime = GetTime()

        -- [[ 1. Check Pending Spells ]]
        for pid, info in pairs(pendingSpells) do
            if (currentTime - info.time) > 5.0 then
                pendingSpells[pid] = nil
            else
                local startTime, duration, enabled = GetSpellCooldownSafe(info.id)
                local isManual = false

                -- Cache Check in Pending
                if (not duration or duration <= GCD_DURATION) then
                    local cachedDur = durationCache[info.id] or MANUAL_COOLDOWNS[info.id]
                    if not cachedDur then
                        local rid = ResolveSpellID(info.name)
                        if rid then cachedDur = durationCache[rid] or MANUAL_COOLDOWNS[rid] end
                    end
                    
                    if cachedDur then
                        startTime = GetTime()
                        duration = cachedDur
                        enabled = 1
                        isManual = true
                    end
                end
                
                -- Standard Retries
                if not isManual and (not duration or duration <= GCD_DURATION) then
                    local st2, dur2, en2 = GetSpellCooldownSafe(info.name)
                    if dur2 and dur2 > GCD_DURATION then
                        startTime, duration, enabled = st2, dur2, en2
                        info.id = info.name
                    end
                end

                if not isManual and (not duration or duration <= GCD_DURATION) then
                    local current, max, chargeStart, chargeDur = GetSpellChargesSafe(info.id)
                    if not chargeDur then 
                        current, max, chargeStart, chargeDur = GetSpellChargesSafe(info.name) 
                        if chargeDur then info.id = info.name end
                    end
                    if chargeDur and chargeDur > GCD_DURATION and current < max then
                        startTime, duration, enabled = chargeStart, chargeDur, 1
                    end
                end

                if enabled == 1 and duration and duration > GCD_DURATION then
                    TrackActiveCooldown(info.unit, info.id, duration, startTime, isManual)
                    pendingSpells[pid] = nil
                end
            end
        end

        -- [[ 2. Items ]]
        for cooldownID, usedTime in pairs(watchItemIDs) do
            if currentTime >= (usedTime + 1) then
                local startTime, duration, enabled = C_Container.GetItemCooldown(cooldownID)
                if enabled == 1 and duration > GCD_DURATION then
                   TrackActiveCooldown("item", cooldownID, duration, startTime)
                end
                watchItemIDs[cooldownID] = nil
            end
        end

        -- [[ 3. Active Cooldowns ]]
        local allInactive = true
        local inCombat = InCombatLockdown()

        for cooldownType, cooldowns in pairs(activeCooldowns) do
            local cooldownFunc = (cooldownType == "item") and C_Container.GetItemCooldown or GetSpellCooldownSafe
            local infoFunc = (cooldownType == "item") and GetItemInfo or GetSpellNameSafe
            
            for cooldownID, data in pairs(cooldowns) do
                allInactive = false
                local remaining = data.endTime - currentTime
                
                if remaining <= 0 then
                     FireNotification(cooldownType, cooldownID, infoFunc)
                     cooldowns[cooldownID] = nil
                else
                    -- Protected Reset Check
                    -- If In Combat OR Manual/Cached, NEVER reset.
                    if not data.isManual and not inCombat then
                        local startTime, duration, enabled = cooldownFunc(cooldownID)
                        local charges = nil
                        if cooldownType ~= "item" then
                             local c, max, cStart, cDur = GetSpellChargesSafe(cooldownID)
                             if cDur then charges = true end
                        end
                        
                        if not charges and (startTime == 0 or not startTime) then
                             if remaining > 1.0 and (currentTime - data.added > 3.0) then
                                  cooldowns[cooldownID] = nil
                             end
                        end
                    end
                    
                    if remaining < updateDelay then updateDelay = remaining end
                end
            end
        end
        
        if updateDelay < MIN_COOLDOWN_UPDATE_DELAY then updateDelay = MIN_COOLDOWN_UPDATE_DELAY end

        if allInactive and not next(watchItemIDs) and not next(pendingSpells) then
            eventFrame:Hide()
        end
        lastUpdate = 0
    end
end

-- ****************************************************************************
-- Init
-- ****************************************************************************
function eventFrame:UNIT_SPELLCAST_SUCCEEDED(unitID, lineID, skillID)
    if unitID == "player" then OnSpellCast("player", skillID)
    elseif unitID == "pet" then OnSpellCast("pet", skillID) end
end
function eventFrame:SPELL_UPDATE_COOLDOWN()
    if not eventFrame:IsVisible() and next(activeCooldowns["player"]) then eventFrame:Show() end
    if next(pendingSpells) then eventFrame:Show() end 
end
function eventFrame:PET_BAR_UPDATE_COOLDOWN()
     if not eventFrame:IsVisible() and next(activeCooldowns["pet"]) then eventFrame:Show() end
end
function eventFrame:PLAYER_ENTERING_WORLD()
    ScanAllCooldowns()
end

local function UpdateRegisteredEvents()
    eventFrame:UnregisterAllEvents()
    local profile = MSBTProfiles.currentProfile
    if profile.events.NOTIFICATION_COOLDOWN.disabled and
       profile.events.NOTIFICATION_PET_COOLDOWN.disabled and
       profile.events.NOTIFICATION_ITEM_COOLDOWN.disabled then
        itemCooldownsEnabled = false
        eventFrame:Hide()
        return
    end
    itemCooldownsEnabled = true
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    eventFrame:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local function Enable() UpdateRegisteredEvents() end
local function Disable()
    eventFrame:Hide()
    eventFrame:UnregisterAllEvents()
    for _, cds in pairs(activeCooldowns) do EraseTable(cds) end
    EraseTable(pendingSpells)
    EraseTable(watchItemIDs)
    EraseTable(spellIDCache)
    EraseTable(durationCache)
end

local function UseActionHook(slot)
    if not itemCooldownsEnabled then return end
    local actionType, itemID = GetActionInfo(slot)
    if actionType == "item" then watchItemIDs[itemID] = GetTime(); eventFrame:Show() end
end
local function UseInventoryItemHook(slot)
    if not itemCooldownsEnabled then return end
    local itemID = GetInventoryItemID("player", slot)
    if itemID then watchItemIDs[itemID] = GetTime(); eventFrame:Show() end
end
local function UseContainerItemHook(bag, slot)
    if not itemCooldownsEnabled then return end
    local itemID = C_Container.GetContainerItemID(bag, slot)
    if itemID then watchItemIDs[itemID] = GetTime(); eventFrame:Show() end
end
local function UseItemByNameHook(itemName)
    if not itemCooldownsEnabled or not itemName then return end
    local _, itemLink = GetItemInfo(itemName)
    local itemID
    if itemLink then itemID = string_match(itemLink, "item:(%d+)") end
    if itemID then watchItemIDs[itemID] = GetTime(); eventFrame:Show() end
end

eventFrame:Hide()
eventFrame:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](self, ...) end end)
eventFrame:SetScript("OnUpdate", OnUpdate)
local _
_, playerClass = UnitClass("player")

hooksecurefunc("UseAction", UseActionHook)
hooksecurefunc("UseInventoryItem", UseInventoryItemHook)
hooksecurefunc(C_Container, "UseContainerItem", UseContainerItemHook)
hooksecurefunc(C_Item, "UseItemByName", UseItemByNameHook)

module.Enable = Enable
module.Disable = Disable
module.UpdateRegisteredEvents = UpdateRegisteredEvents