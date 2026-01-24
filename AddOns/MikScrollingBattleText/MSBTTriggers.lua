-- Title: Mik's Scrolling Battle Text Triggers
-- Author: Mikord (12.0.1 Restoration - Phase 17 Sticky Logic Fix)
-- Status: RESTORED (Robust Sticky Detection + Font Support)

local module = {}
local moduleName = "Triggers"
if not MikSBT then return end
MikSBT[moduleName] = module

local MSBTProfiles = MikSBT.Profiles
local triggerFrame = CreateFrame("Frame")
local throttleTimers = {}

-- REQUIRED TABLES
module.triggerSuppressions = {}
module.exceptions = {} 
module.powerTypes = {[0]="Mana",[1]="Rage",[2]="Focus",[3]="Energy"}

module.ConvertType = function(v)
    if v == "true" then return true end
    if v == "false" then return false end
    return tonumber(v) or v
end

-- ****************************************************************************
-- HELPER: SOUND TRANSLATOR
-- ****************************************************************************
local function PlayTriggerSound(soundName)
    if not soundName or soundName == "" then return end
    local path = soundName
    if soundName == "MSBT Low Health" then
        path = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\LowHealth.ogg"
    elseif soundName == "MSBT Low Mana" then
        path = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\LowMana.ogg"
    elseif soundName == "MSBT Cooldown" then
        path = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\Cooldown.ogg"
    end
    local played = pcall(PlaySoundFile, path, "Master")
    if not played then pcall(PlaySound, tonumber(path), "Master") end
end

-- ****************************************************************************
-- CORE: TRIGGER EXECUTOR
-- ****************************************************************************
local function FireTrigger(triggerSettings, eventData)
    local now = GetTime()
    local throttle = triggerSettings.throttle or 0
    if (throttle > 0 and throttleTimers[triggerSettings] and (now - throttleTimers[triggerSettings] < throttle)) then
        return
    end
    throttleTimers[triggerSettings] = now

    local message = triggerSettings.message
    if (MikSBT.Main and MikSBT.Main.FormatMessage) then
        message = MikSBT.Main.FormatMessage(message, eventData)
    end

    if (message and message ~= "") then
        local scrollArea = triggerSettings.scrollArea or "Notification" 
        
        -- [[ STICKY LOGIC FIX ]]
        -- We check 'sticky' AND 'alwaysSticky' (legacy key).
        -- We accept boolean true, string "true", or number 1.
        local rawSticky = triggerSettings.sticky or triggerSettings.alwaysSticky
        local isSticky = false

        if rawSticky == true or rawSticky == "true" then 
            isSticky = true
        elseif type(rawSticky) == "number" and rawSticky ~= 0 then 
            isSticky = true 
        elseif rawSticky == "1" then 
            isSticky = true
        end
        
        local r = (triggerSettings.colorR or 255)
        local g = (triggerSettings.colorG or 0)
        local b = (triggerSettings.colorB or 0)
        
        -- Color Safety
        if r <= 1 and g <= 1 and b <= 1 and (r+g+b > 0) then r=r*255 g=g*255 b=b*255 end

        -- Font Settings
        local fontSize = triggerSettings.fontSize
        local fontName = triggerSettings.fontName
        local outlineIndex = triggerSettings.outlineIndex

        -- Pass isSticky to engine to trigger "Pow"/"Jiggle" styles
        MikSBT.Animations.DisplayMessage(
            message, 
            scrollArea, 
            isSticky, 
            r, g, b, 
            fontSize, fontName, outlineIndex
        )
    end

    PlayTriggerSound(triggerSettings.soundFile)
end

-- ****************************************************************************
-- SMART HOOK
-- ****************************************************************************
local function OnLowHealthDetected()
    local profile = MSBTProfiles.currentProfile
    
    if profile and profile.triggers then
        for triggerID, trigger in pairs(profile.triggers) do
            if (trigger.disabled ~= true) then
                local isMatch = false
                if triggerID == "MSBT_TRIGGER_LOW_HEALTH" then isMatch = true end
                if not isMatch and type(triggerID)=="string" and string.find(triggerID, "LowHealth") then isMatch = true end
                
                if isMatch then
                    FireTrigger(trigger, {unitID = "player", amount = 0})
                end
            end
        end
    end
end

local function InitializeHooks()
    if LowHealthFrame then
        LowHealthFrame:HookScript("OnShow", function() OnLowHealthDetected() end)
        if LowHealthFrame:IsShown() then OnLowHealthDetected() end
    end
end

-- Standard Logic
local function TestCondition(condition, unit)
    local cType = condition.conditionType
    if (cType == "TEST_H_PCT" or cType == "TEST_P_PCT") then return false end

    if (cType == "TEST_BUFF" or cType == "TEST_DEBUFF") then
        local spellName = condition.parameter
        local filter = (cType == "TEST_BUFF") and "HELPFUL" or "HARMFUL"
        for i=1, 40 do
            local name = UnitAura(unit, i, filter)
            if (not name) then break end
            if (name == spellName) then return true end
        end
        return false
    end
    if (cType == "TEST_COOLDOWN") then
        local start, duration = GetSpellCooldown(condition.parameter)
        return (start == 0 and duration == 0)
    end
    return false
end

module.UpdateTriggers = function(event, unit)
    if (not MSBTProfiles) then MSBTProfiles = MikSBT.Profiles end
    if (not MikSBT.db or not MikSBT.db.global) then return end
    if (MikSBT.db.global.triggersDisabled) then return end

    local currentProfile = MSBTProfiles.currentProfile
    if (not currentProfile or not currentProfile.triggers) then return end

    for triggerID, trigger in pairs(currentProfile.triggers) do
        if (trigger.disabled ~= true) then
            local skip = false
            if triggerID == "MSBT_TRIGGER_LOW_HEALTH" then skip = true end
            if not skip and trigger.conditions then
                for _, c in ipairs(trigger.conditions) do
                    if c.conditionType == "TEST_H_PCT" then skip = true end
                end
            end

            if not skip then
                local conditionsMet = true
                if (trigger.conditions) then
                    for _, condition in ipairs(trigger.conditions) do
                        if (not TestCondition(condition, unit or "player")) then
                            conditionsMet = false
                            break
                        end
                    end
                end

                if (conditionsMet) then
                    FireTrigger(trigger, {unitID = unit})
                end
            end
        end
    end
end

triggerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
triggerFrame:RegisterEvent("UNIT_AURA")
triggerFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
triggerFrame:SetScript("OnEvent", function(self, event, ...)
    local unit = ...
    if event == "PLAYER_ENTERING_WORLD" then
        InitializeHooks()
    elseif event == "UNIT_AURA" or event == "SPELL_UPDATE_COOLDOWN" then
        if (unit == "player" or unit == "target" or not unit) then
            module.UpdateTriggers(event, unit)
        end
    end
end)

module.Enable = function() end 
module.Disable = function() triggerFrame:UnregisterAllEvents() end
module.HandleCooldowns = function() module.UpdateTriggers("SPELL_UPDATE_COOLDOWN") end