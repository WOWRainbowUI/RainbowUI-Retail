--- START OF FILE MSBTMain.lua ---
-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Main
-- Author: Mikord (12.0.1 Restoration Phase 16 - Clean Text)
-- Status: Interrupts Fixed, Falling Fixed, "Unknown" Text Removed
-------------------------------------------------------------------------------
local module = {}
local moduleName = "Main"
MikSBT[moduleName] = module

-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------
local MSBTAnimations = MikSBT.Animations
local MSBTMedia = MikSBT.Media
local MSBTParser = MikSBT.Parser
local MSBTTriggers = MikSBT.Triggers
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

local table_remove = table.remove
local string_find = string.find
local string_gsub = string.gsub
local string_format = string.format
local string_match = string.match
local math_abs = math.abs
local bit_bor = bit.bor
local FormatLargeNumber = BreakUpLargeNumbers
local GetTime = GetTime

local EraseTable = MikSBT.EraseTable
local GetSkillName = MikSBT.GetSkillName
local GetSpellInfo = MikSBT.GetSpellInfo
local ShortenNumber = MikSBT.ShortenNumber
local DisplayEvent = MSBTAnimations.DisplayEvent
local IsScrollAreaActive = MSBTAnimations.IsScrollAreaActive
local IsScrollAreaIconShown = MSBTAnimations.IsScrollAreaIconShown
local TestFlagsAll = MSBTParser.TestFlagsAll

local triggerSuppressions = MSBTTriggers and MSBTTriggers.triggerSuppressions or
                                {}
local powerTypes = MSBTTriggers and MSBTTriggers.powerTypes or {}
local classMap = MSBTParser.classMap
local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-------------------------------------------------------------------------------
-- 12.0.1 GRAVITY SENSOR
-- Tracks falling state to fix Environmental Damage and Deduplicate events.
-------------------------------------------------------------------------------
local lastFallTime = 0
local gravityTracker = CreateFrame("Frame")
gravityTracker:SetScript("OnUpdate", function()
    if IsFalling() then lastFallTime = GetTime() end
end)

-------------------------------------------------------------------------------
-- Constants & Variables
-------------------------------------------------------------------------------
local MERGE_DELAY_TIME = 0.3
local THROTTLE_UPDATE_TIME = 0.5
local EMOTE_HOLD_TIME = 1
local ENEMY_BUFF_HOLD_TIME = 5

local DAMAGETYPE_PHYSICAL = 0x1
local DAMAGETYPE_HOLY = 0x2
local DAMAGETYPE_FIRE = 0x4
local DAMAGETYPE_NATURE = 0x8
local DAMAGETYPE_FROST = 0x10
local DAMAGETYPE_SHADOW = 0x20
local DAMAGETYPE_ARCANE = 0x40

local DAMAGETYPE_SPELLSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_ARCANE
local DAMAGETYPE_FLAMESTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FIRE
local DAMAGETYPE_FROSTSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FROST
local DAMAGETYPE_STORMSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_NATURE
local DAMAGETYPE_SHADOWSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_SHADOW
local DAMAGETYPE_HOLYSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY
local DAMAGETYPE_SPELLFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLFROST = DAMAGETYPE_FROST + DAMAGETYPE_ARCANE
local DAMAGETYPE_DIVINE = DAMAGETYPE_HOLY + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLSHADOW = DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_HOLYFIRE = DAMAGETYPE_HOLY + DAMAGETYPE_FIRE
local DAMAGETYPE_HOLYSTORM = DAMAGETYPE_HOLY + DAMAGETYPE_NATURE
local DAMAGETYPE_HOLYFROST = DAMAGETYPE_HOLY + DAMAGETYPE_FROST
local DAMAGETYPE_FIRESTORM = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE
local DAMAGETYPE_SHADOWFLAME = DAMAGETYPE_FIRE + DAMAGETYPE_SHADOW
local DAMAGETYPE_FROSTFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_FROST
local DAMAGETYPE_FROSTSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_FROST
local DAMAGETYPE_SHADOWFROST = DAMAGETYPE_FROST + DAMAGETYPE_SHADOW
local DAMAGETYPE_SHADOWHOLY = DAMAGETYPE_HOLY + DAMAGETYPE_SHADOW
local DAMAGETYPE_SHADOWSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW
local DAMAGETYPE_ELEMENTAL = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE +
                                 DAMAGETYPE_FROST
local DAMAGETYPE_COSMIC = DAMAGETYPE_HOLY + DAMAGETYPE_NATURE +
                              DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_CHROMATIC = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE +
                                 DAMAGETYPE_FROST + DAMAGETYPE_SHADOW +
                                 DAMAGETYPE_ARCANE
local DAMAGETYPE_MAGIC =
    DAMAGETYPE_ARCANE + DAMAGETYPE_FIRE + DAMAGETYPE_FROST + DAMAGETYPE_NATURE +
        DAMAGETYPE_SHADOW + DAMAGETYPE_HOLY
local DAMAGETYPE_CHAOS =
    DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY + DAMAGETYPE_FIRE + DAMAGETYPE_NATURE +
        DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE

local SPELLID_AUTOSHOT = 75
local SPELL_BLINK = GetSkillName(1953)
local SPELL_BLOOD_STRIKE = WOW_PROJECT_ID < WOW_PROJECT_CLASSIC and
                               GetSkillName(60945)
local SPELL_RAIN_OF_FIRE = GetSkillName(5740)

local _
local eventFrame = CreateFrame("Frame")
local throttleFrame = CreateFrame("Frame")
local playerClass
local combatEventCache = {}
local eventHandlers = {}
local damageTypeMap = {}
local damageColorProfileEntries = {}
local powerTokens = {}
local uniquePowerTypes = {}
local throttledAbilities = {}
local unmergedEvents = {}
local mergedEvents = {}
local lastMergeUpdate = 0
local lastThrottleUpdate = 0
local isEnglish
local lastPowerAmounts = {}
local recentEmotes = {}
local recentEnemyBuffs = {}
local ignoreAuras = {}
local activePlayerAuras = {}
local offHandTrailer
local offHandPattern

-------------------------------------------------------------------------------
-- Utility functions
-------------------------------------------------------------------------------
local function IsSecret(val)
    if issecretvalue and issecretvalue(val) then return true end
    return false
end

local function CreatePattern(globalString)
    if not globalString then return "" end
    local pattern = string.gsub(globalString, "([%(%)%.%%%+%-%*%?%[%^%$])",
                                "%%%1")
    pattern = string.gsub(pattern, "%%%%s", "(.*)")
    pattern = string.gsub(pattern, "%%%%d", "(%%d+)")
    return pattern
end

local PATTERN_XP_SIMPLE = CreatePattern(COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED)
local PATTERN_XP_FULL = CreatePattern(COMBATLOG_XPGAIN_FIRSTPERSON)
local PATTERN_REP_INC = CreatePattern(FACTION_STANDING_INCREASED)
local PATTERN_REP_DEC = CreatePattern(FACTION_STANDING_DECREASED)
local PATTERN_KILL_SELF = CreatePattern(SELFKILL)
local PATTERN_FALLING = CreatePattern(
                            COMBATLOG_ENVIRONMENTAL_DAMAGE_FALLING_SELF)


-- Credit to ch0psu3ybr
-- Thanks for the insight
local function CreateDamageMaps()
damageTypeMap[DAMAGETYPE_PHYSICAL] = STRING_SCHOOL_PHYSICAL
damageTypeMap[DAMAGETYPE_HOLY] = STRING_SCHOOL_HOLY
damageTypeMap[DAMAGETYPE_FIRE] = STRING_SCHOOL_FIRE
damageTypeMap[DAMAGETYPE_NATURE] = STRING_SCHOOL_NATURE
damageTypeMap[DAMAGETYPE_FROST] = STRING_SCHOOL_FROST
damageTypeMap[DAMAGETYPE_SHADOW] = STRING_SCHOOL_SHADOW
damageTypeMap[DAMAGETYPE_ARCANE] = STRING_SCHOOL_ARCANE
damageTypeMap[DAMAGETYPE_HOLYSTRIKE] = STRING_SCHOOL_HOLYSTRIKE
damageTypeMap[DAMAGETYPE_FLAMESTRIKE] = STRING_SCHOOL_FLAMESTRIKE
damageTypeMap[DAMAGETYPE_STORMSTRIKE] = STRING_SCHOOL_STORMSTRIKE
damageTypeMap[DAMAGETYPE_SHADOWSTRIKE] = STRING_SCHOOL_SHADOWSTRIKE
damageTypeMap[DAMAGETYPE_FROSTSTRIKE] = STRING_SCHOOL_FROSTSTRIKE
damageTypeMap[DAMAGETYPE_SPELLSTRIKE] = STRING_SCHOOL_SPELLSTRIKE
damageTypeMap[DAMAGETYPE_HOLYFIRE] = STRING_SCHOOL_HOLYFIRE
damageTypeMap[DAMAGETYPE_SHADOWHOLY] = STRING_SCHOOL_SHADOWHOLY
damageTypeMap[DAMAGETYPE_DIVINE] = STRING_SCHOOL_DIVINE
damageTypeMap[DAMAGETYPE_HOLYSTORM] = STRING_SCHOOL_HOLYSTORM
damageTypeMap[DAMAGETYPE_HOLYFROST] = STRING_SCHOOL_HOLYFROST
damageTypeMap[DAMAGETYPE_FIRESTORM] = STRING_SCHOOL_FIRESTORM
damageTypeMap[DAMAGETYPE_FROSTFIRE] = STRING_SCHOOL_FROSTFIRE
damageTypeMap[DAMAGETYPE_SHADOWFLAME] = STRING_SCHOOL_SHADOWFLAME
damageTypeMap[DAMAGETYPE_SPELLFIRE] = STRING_SCHOOL_SPELLFIRE
damageTypeMap[DAMAGETYPE_FROSTSTORM] = STRING_SCHOOL_FROSTSTORM
damageTypeMap[DAMAGETYPE_SHADOWSTORM] = STRING_SCHOOL_SHADOWSTORM
damageTypeMap[DAMAGETYPE_SPELLSTORM] = STRING_SCHOOL_SPELLSTORM
damageTypeMap[DAMAGETYPE_SHADOWFROST] = STRING_SCHOOL_SHADOWFROST
damageTypeMap[DAMAGETYPE_SPELLFROST] = STRING_SCHOOL_SPELLFROST
damageTypeMap[DAMAGETYPE_SPELLSHADOW] = STRING_SCHOOL_SPELLSHADOW
damageTypeMap[DAMAGETYPE_ELEMENTAL] = STRING_SCHOOL_ELEMENTAL
damageTypeMap[DAMAGETYPE_COSMIC] = STRING_SCHOOL_COSMIC
damageTypeMap[DAMAGETYPE_CHROMATIC] = STRING_SCHOOL_CHROMATIC
damageTypeMap[DAMAGETYPE_MAGIC] = STRING_SCHOOL_MAGIC
damageTypeMap[DAMAGETYPE_CHAOS] = STRING_SCHOOL_CHAOS

-- Create the damage color profile entries lookup map.
damageColorProfileEntries[DAMAGETYPE_PHYSICAL] = "physical"
damageColorProfileEntries[DAMAGETYPE_HOLY] = "holy"
damageColorProfileEntries[DAMAGETYPE_FIRE] = "fire"
damageColorProfileEntries[DAMAGETYPE_NATURE] = "nature"
damageColorProfileEntries[DAMAGETYPE_FROST] = "frost"
damageColorProfileEntries[DAMAGETYPE_SHADOW] = "shadow"
damageColorProfileEntries[DAMAGETYPE_ARCANE] = "arcane"
damageColorProfileEntries[DAMAGETYPE_HOLYSTRIKE] = "holystrike"
damageColorProfileEntries[DAMAGETYPE_FLAMESTRIKE] = "flamestrike"
damageColorProfileEntries[DAMAGETYPE_STORMSTRIKE] = "stormstrike"
damageColorProfileEntries[DAMAGETYPE_FROSTSTRIKE] = "froststrike"
damageColorProfileEntries[DAMAGETYPE_SHADOWSTRIKE] = "shadowstrike"
damageColorProfileEntries[DAMAGETYPE_SPELLSTRIKE] = "spellstrike"
damageColorProfileEntries[DAMAGETYPE_HOLYFIRE] = "radiant"
damageColorProfileEntries[DAMAGETYPE_SHADOWHOLY] = "twilight"
damageColorProfileEntries[DAMAGETYPE_DIVINE] = "divine"
damageColorProfileEntries[DAMAGETYPE_HOLYSTORM] = "holystorm"
damageColorProfileEntries[DAMAGETYPE_HOLYFROST] = "holyfrost"
damageColorProfileEntries[DAMAGETYPE_FIRESTORM] = "volcanic"
damageColorProfileEntries[DAMAGETYPE_FROSTFIRE] = "frostfire"
damageColorProfileEntries[DAMAGETYPE_SHADOWFLAME] = "shadowflame"
damageColorProfileEntries[DAMAGETYPE_SPELLFIRE] = "spellfire"
damageColorProfileEntries[DAMAGETYPE_FROSTSTORM] = "froststorm"
damageColorProfileEntries[DAMAGETYPE_SHADOWSTORM] = "plague"
damageColorProfileEntries[DAMAGETYPE_SPELLSTORM] = "astral"
damageColorProfileEntries[DAMAGETYPE_SHADOWFROST] = "shadowfrost"
damageColorProfileEntries[DAMAGETYPE_SPELLFROST] = "spellfrost"
damageColorProfileEntries[DAMAGETYPE_SPELLSHADOW] = "spellshadow"
damageColorProfileEntries[DAMAGETYPE_ELEMENTAL] = "elemental"
damageColorProfileEntries[DAMAGETYPE_COSMIC] = "cosmic"
damageColorProfileEntries[DAMAGETYPE_CHROMATIC] = "chromatic"
damageColorProfileEntries[DAMAGETYPE_MAGIC] = "magic"
damageColorProfileEntries[DAMAGETYPE_CHAOS] = "chaos"
end

local function AbbreviateSkillName(skillName)
    if (string_find(skillName, "[%s%-]")) then
        skillName = string_gsub(skillName, "(%a)[%l%p]*[%s%-]*", "%1")
    end
    return skillName
end

local function FormatPartialEffects(absorbAmount, blockAmount, resistAmount,
                                    isGlancing, isCrushing)
    local currentProfile = MSBTProfiles.currentProfile
    local effectSettings, amount
    local partialEffectText = ""

    if absorbAmount then
        effectSettings = currentProfile.absorb
        amount = absorbAmount
    elseif blockAmount then
        effectSettings = currentProfile.block
        amount = blockAmount
    elseif resistAmount then
        effectSettings = currentProfile.resist
        amount = resistAmount
    end

    local trailer = effectSettings and effectSettings.trailer
    if trailer and not effectSettings.disabled then
        local formattedAmount = amount
        if currentProfile.shortenNumbers then
            formattedAmount = ShortenNumber(formattedAmount,
                                            currentProfile.shortenNumberPrecision)
        elseif currentProfile.groupNumbers then
            formattedAmount = FormatLargeNumber(formattedAmount)
        end
        trailer = string_gsub(trailer, "%%a", formattedAmount)
        if not currentProfile.partialColoringDisabled then
            partialEffectText = string_format("|cFF%02x%02x%02x%s|r",
                                              effectSettings.colorR * 255,
                                              effectSettings.colorG * 255,
                                              effectSettings.colorB * 255,
                                              trailer)
        else
            partialEffectText = trailer
        end
    end

    effectSettings = nil
    trailer = nil

    if isGlancing then
        effectSettings = currentProfile.glancing
    elseif isCrushing then
        effectSettings = currentProfile.crushing
    end

    trailer = effectSettings and effectSettings.trailer
    if trailer and not effectSettings.disabled then
        if not currentProfile.partialColoringDisabled then
            partialEffectText = partialEffectText ..
                                    string_format("|cFF%02x%02x%02x%s|r",
                                                  effectSettings.colorR * 255,
                                                  effectSettings.colorG * 255,
                                                  effectSettings.colorB * 255,
                                                  trailer)
        else
            partialEffectText = partialEffectText .. trailer
        end
    end

    return partialEffectText
end

-- ****************************************************************************
-- Formats an event with the parameters.
-- ****************************************************************************
local function FormatEvent(message, amount, damageType, overhealAmount,
                           overkillAmount, powerType, name, class, effectName,
                           partialEffects, mergeTrailer, ignoreDamageColoring,
                           hideSkills, hideNames)
    -- [[ 12.0.1 SECRET GUARD & TEXT CLEANUP ]]
    -- If values are secret (userdata) or nil, set them to empty strings.
    -- We rely on the regex at the end to clean up the ugly "()" artifacts.
    if effectName == nil or IsSecret(effectName) or type(effectName) ~= "string" then
        effectName = ""
    end
    if name == nil or IsSecret(name) or type(name) ~= "string" then name = "" end
    -- [[ END GUARD ]]

    local currentProfile = MSBTProfiles.currentProfile
    local checkParens

    if amount and string_find(message, "%a", 1, true) then
        local partialAmount = ""
        if overhealAmount and overhealAmount > 0 and
            not currentProfile.overheal.disabled then
            amount = amount - overhealAmount
            partialAmount = overhealAmount
            if currentProfile.shortenNumbers then
                partialAmount = ShortenNumber(partialAmount,
                                              currentProfile.shortenNumberPrecision)
            elseif currentProfile.groupNumbers then
                partialAmount = FormatLargeNumber(partialAmount)
            end
            local overhealSettings = currentProfile.overheal
            partialAmount = string_gsub(overhealSettings.trailer, "%%a",
                                        partialAmount)
            if not currentProfile.partialColoringDisabled then
                partialAmount = string_format("|cFF%02x%02x%02x%s|r",
                                              overhealSettings.colorR * 255,
                                              overhealSettings.colorG * 255,
                                              overhealSettings.colorB * 255,
                                              partialAmount)
            end
        elseif overkillAmount and overkillAmount > 0 and
            not currentProfile.overkill.disabled then
            amount = amount - overkillAmount
            partialAmount = overkillAmount
            if currentProfile.shortenNumbers then
                partialAmount = ShortenNumber(partialAmount,
                                              currentProfile.shortenNumberPrecision)
            elseif currentProfile.groupNumbers then
                partialAmount = FormatLargeNumber(partialAmount)
            end
            local overkillSettings = currentProfile.overkill
            partialAmount = string_gsub(overkillSettings.trailer, "%%a",
                                        partialAmount)
            if not currentProfile.partialColoringDisabled then
                partialAmount = string_format("|cFF%02x%02x%02x%s|r",
                                              overkillSettings.colorR * 255,
                                              overkillSettings.colorG * 255,
                                              overkillSettings.colorB * 255,
                                              partialAmount)
            end
        end

        local formattedAmount = amount
        if currentProfile.shortenNumbers then
            formattedAmount = ShortenNumber(formattedAmount,
                                            currentProfile.shortenNumberPrecision)
        elseif currentProfile.groupNumbers then
            formattedAmount = FormatLargeNumber(formattedAmount)
        end

        if damageType and not ignoreDamageColoring and
            not currentProfile.damageColoringDisabled then
            local damageSettings =
                currentProfile[damageColorProfileEntries[damageType]]
            if damageSettings and not damageSettings.disabled then
                formattedAmount = string_format("|cFF%02x%02x%02x%s|r",
                                                damageSettings.colorR * 255,
                                                damageSettings.colorG * 255,
                                                damageSettings.colorB * 255,
                                                formattedAmount)
            end
        end

        message = string_gsub(message, "%%a", formattedAmount .. partialAmount)
    end

    if powerType and string_find(message, "%p", 1, true) then
        local powerString = _G[powerTokens[powerType] or "UNKNOWN"]
        message = string_gsub(message, "%%p", powerString or UNKNOWN)
    end

    if name and string_find(message, "%n", 1, true) then
        if hideNames or name == "" then
            message = string_gsub(message, "%s?%-?%s?%%n", "")
            checkParens = true
        else
            if string_find(name, "-", 1, true) then
                name = string_gsub(name, "(.-)%-.*", "%1")
            end
            if class and not currentProfile.classColoringDisabled then
                local classSettings = currentProfile[class]
                if classSettings and not classSettings.disabled then
                    name = string_format("|cFF%02x%02x%02x%s|r",
                                         classSettings.colorR * 255,
                                         classSettings.colorG * 255,
                                         classSettings.colorB * 255, name)
                end
            end
            message = string_gsub(message, "%%n", name)
        end
    else
        message = string_gsub(message, "%%n", "")
        checkParens = true
    end

    if effectName and string_find(message, "%e", 1, true) then
        message = string_gsub(message, "%%e", effectName)
    end

    if effectName and effectName ~= "" then
        if string_find(message, "%s", 1, true) then
            if (hideSkills) then
                message = string_gsub(message, "%s?%-?%s?%%sl?%s?%-?%s?", "")
                checkParens = true
            else
                local isChanged
                local success, sub = pcall(function()
                    return currentProfile.abilitySubstitutions[effectName]
                end)
                if success and sub then
                    effectName = sub
                    isChanged = true
                end

                if string_find(message, "%sl", 1, true) then
                    message = string_gsub(message, "%%sl", effectName)
                end
                if isEnglish and not isChanged and
                    currentProfile.abbreviateAbilities then
                    effectName = AbbreviateSkillName(effectName)
                end
                message = string_gsub(message, "%%s", effectName)
            end
        end
    else
        -- If effect name is missing (Secret), remove the placeholders
        message = string_gsub(message, "%%s", "")
        message = string_gsub(message, "%%sl", "")
        message = string_gsub(message, "%%e", "")
        checkParens = true
    end

    if checkParens then
        message = string_gsub(message, "%(%)", "")
        message = string_gsub(message, "%[%]", "")
        message = string_gsub(message, "%{%}", "")
        message = string_gsub(message, "%<%>", "")
        -- Aggressive cleanup for " - " leftovers
        message = string_gsub(message, "%( %- %)", "")
        message = string_gsub(message, "%(  %)", "")
        message = string_gsub(message, "^%s+", "")
    end

    if damageType and string_find(message, "%t", 1, true) then
        message = string_gsub(message, "%%t", damageTypeMap[damageType] or
                                  STRING_SCHOOL_UNKNOWN)
    end

    if partialEffects then message = message .. partialEffects end

    if mergeTrailer then message = message .. mergeTrailer end

    return message
end

local function GetInOutEventData(parserEvent)
    local eventTypeString, affectedUnitName, affectedUnitClass
    if parserEvent.recipientUnit == "player" then
        affectedUnitName = parserEvent.sourceName
        eventTypeString = "INCOMING"
        affectedUnitClass = classMap and classMap[parserEvent.sourceGUID] or nil
    elseif parserEvent.sourceUnit == "player" then
        affectedUnitName = parserEvent.recipientName
        eventTypeString = "OUTGOING"
        affectedUnitClass = classMap and classMap[parserEvent.recipientGUID] or nil
    elseif parserEvent.recipientUnit == "pet" then
        affectedUnitName = parserEvent.sourceName
        eventTypeString = "PET_INCOMING"
        affectedUnitClass = classMap and classMap[parserEvent.sourceGUID] or nil
    elseif parserEvent.sourceUnit == "pet" then
        affectedUnitName = parserEvent.recipientName
        eventTypeString = "PET_OUTGOING"
        affectedUnitClass = classMap and classMap[parserEvent.recipientGUID] or nil
    end
    return eventTypeString, affectedUnitName, affectedUnitClass
end
local function DetectPowerGain(powerAmount, powerType)
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_POWER_GAIN
    if eventSettings.disabled or not powerType then return end
    local lastPowerAmount = lastPowerAmounts[powerType] or 65535
    if powerAmount > lastPowerAmount then
        DisplayEvent(eventSettings,
                     FormatEvent(eventSettings.message,
                                 powerAmount - lastPowerAmount, nil, nil, nil,
                                 powerType, nil, nil, UNKNOWN))
    end
end

local function HandleComboPoints(amount, powerType)
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_CP_GAIN
    local maxAmount = UnitPowerMax("player", powerType)
    if amount == maxAmount then
        eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CP_FULL
    end
    if eventSettings.disabled or amount == 0 then return end
    if amount <= 0 then return end
    DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleChi(amount, powerType)
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_CHI_CHANGE
    local maxAmount = UnitPowerMax("player", powerType)
    if amount == maxAmount then
        eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CHI_FULL
    end
    if eventSettings.disabled or amount <= 0 then return end
    DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleArcanePower(amount, powerType)
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_AC_CHANGE
    local maxAmount = UnitPowerMax("player", powerType)
    if amount == maxAmount then
        eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_AC_FULL
    end
    if eventSettings.disabled or amount <= 0 then return end
    DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleHolyPower(amount, powerType)
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_HOLY_POWER_CHANGE
    local maxAmount = UnitPowerMax("player", powerType)
    if amount == maxAmount then
        eventSettings = MSBTProfiles.currentProfile.events
                            .NOTIFICATION_HOLY_POWER_FULL
    end
    if eventSettings.disabled or amount == 0 then return end
    if amount <= 0 then return end
    DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleEssence(amount, powerType)
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_ESSENCE_CHANGE
    local maxAmount = UnitPowerMax("player", powerType)
    if (amount == maxAmount) then
        eventSettings = MSBTProfiles.currentProfile.events
                            .NOTIFICATION_ESSENCE_FULL
    end
    if (eventSettings.disabled or amount == 0) then return end
    if amount <= 0 then return end
    DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleMonsterEmotes(emoteString)
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_MONSTER_EMOTE
    if eventSettings.disabled then return end

    local now = GetTime()
    for emote, cleanupTime in pairs(recentEmotes) do
        if now >= cleanupTime then recentEmotes[emote] = nil end
    end
    if recentEmotes[emoteString] then return end

    DisplayEvent(eventSettings,
                 FormatEvent(eventSettings.message, nil, nil, nil, nil, nil,
                             nil, nil, emoteString))
    recentEmotes[emoteString] = now + EMOTE_HOLD_TIME
end

local function MergeEvents(numEvents, currentProfile)
    local unmergedEvent
    local doMerge = false

    for i = 1, numEvents do
        unmergedEvent = unmergedEvents[i]
        for _, mergedEvent in ipairs(mergedEvents) do
            if unmergedEvent.eventType == mergedEvent.eventType then
                if not unmergedEvent.effectName then
                    if unmergedEvent.name == mergedEvent.name and
                        unmergedEvent.name then
                        doMerge = true
                    end
                elseif unmergedEvent.effectName == mergedEvent.effectName then
                    -- Use mergeID for accurate per-target merging (handles secret values)
                    if unmergedEvent.mergeID and mergedEvent.mergeID then
                        if unmergedEvent.mergeID ~= mergedEvent.mergeID then
                            mergedEvent.name = L.MSG_MULTIPLE_TARGETS
                        end
                    elseif unmergedEvent.name ~= mergedEvent.name then
                        mergedEvent.name = L.MSG_MULTIPLE_TARGETS
                    end
                    if unmergedEvent.class ~= mergedEvent.class then
                        mergedEvent.class = nil
                    end
                    doMerge = true
                end
            end

            if doMerge then
                mergedEvent.partialEffects = nil
                unmergedEvent.eventMerged = true
                if unmergedEvent.amount then
                    mergedEvent.amount =
                        (mergedEvent.amount or 0) + unmergedEvent.amount
                end
                if unmergedEvent.overhealAmount then
                    mergedEvent.overhealAmount =
                        (mergedEvent.overhealAmount or 0) +
                            unmergedEvent.overhealAmount
                end
                mergedEvent.numMerged = mergedEvent.numMerged + 1
                if unmergedEvent.isCrit then
                    mergedEvent.numCrits = mergedEvent.numCrits + 1
                else
                    mergedEvent.isCrit = false
                end
                break
            end
        end

        if not doMerge then
            unmergedEvent.numMerged = 0
            if unmergedEvent.isCrit then
                unmergedEvent.numCrits = 1
            else
                unmergedEvent.numCrits = 0
            end
            mergedEvents[#mergedEvents + 1] = unmergedEvent
        end
        doMerge = false
    end

    if not currentProfile.hideMergeTrailer then
        for _, mergedEvent in ipairs(mergedEvents) do
            if mergedEvent.numMerged > 0 then
                local critTrailer = ""
                if mergedEvent.numCrits > 0 then
                    critTrailer = string_format(", %d %s", mergedEvent.numCrits,
                                                mergedEvent.numCrits == 1 and
                                                    L.MSG_CRIT or L.MSG_CRITS)
                end
                mergedEvent.mergeTrailer =
                    string_format(" [%d %s%s]", mergedEvent.numMerged + 1,
                                  L.MSG_HITS, critTrailer)
            end
        end
    end

    for i = 1, numEvents do
        if unmergedEvents[1].eventMerged then
            EraseTable(unmergedEvents[1])
            combatEventCache[#combatEventCache + 1] = unmergedEvents[1]
        end
        table_remove(unmergedEvents, 1)
    end
end

-------------------------------------------------------------------------------
-- Event handlers
-------------------------------------------------------------------------------
local function DamageHandler(parserEvent, currentProfile)
    local eventTypeString, affectedUnitName, affectedUnitClass =
        GetInOutEventData(parserEvent)
    if not eventTypeString then return end
    if parserEvent.amount and parserEvent.amount <
        currentProfile.damageThreshold then return end

    -- [[ 12.0.1 DEDUPLICATION ]]
    if parserEvent.damageType == DAMAGETYPE_PHYSICAL and
        parserEvent.recipientUnit == "player" then
        if (GetTime() - lastFallTime) < 0.5 then return nil end
    end

    local skillID = parserEvent.skillID
    if skillID == SPELLID_AUTOSHOT then skillID = nil end
    if skillID then eventTypeString = eventTypeString .. "_SPELL" end
    eventTypeString = eventTypeString ..
                          (parserEvent.isDoT and "_DOT" or
                              parserEvent.isDamageShield and "_DAMAGE_SHIELD" or
                              "_DAMAGE")
    return eventTypeString, parserEvent.skillName, affectedUnitName,
           affectedUnitClass, true
end

local function MissHandler(parserEvent, currentProfile)
    local eventTypeString, affectedUnitName, affectedUnitClass =
        GetInOutEventData(parserEvent)
    if not eventTypeString then return end
    local skillID = parserEvent.skillID
    if skillID == SPELLID_AUTOSHOT then skillID = nil end
    if skillID then eventTypeString = eventTypeString .. "_SPELL" end
    eventTypeString = eventTypeString .. "_" .. parserEvent.missType
    return eventTypeString, parserEvent.skillName, affectedUnitName,
           affectedUnitClass, true
end

local function HealHandler(parserEvent, currentProfile)
    local eventTypeString, affectedUnitName, affectedUnitClass =
        GetInOutEventData(parserEvent)
    if not eventTypeString then return end
    local isHoT = parserEvent.isHoT
    local amount = parserEvent.amount
    if amount then
        if amount < currentProfile.healThreshold then return end
        local overhealAmount = parserEvent.overhealAmount
        local effectiveHealAmount =
            overhealAmount and (amount - overhealAmount) or amount
        if effectiveHealAmount == 0 then
            if not isHoT and currentProfile.hideFullOverheals then
                return
            end
            if isHoT and currentProfile.hideFullHoTOverheals then
                return
            end
        end
    end
    if parserEvent.sourceName == parserEvent.recipientName then
        eventTypeString = "SELF"
    end
    eventTypeString = eventTypeString .. (isHoT and "_HOT" or "_HEAL")
    return eventTypeString, parserEvent.skillName, affectedUnitName,
           affectedUnitClass, true
end

local function InterruptHandler(parserEvent, currentProfile)
    local eventTypeString, affectedUnitName, affectedUnitClass =
        GetInOutEventData(parserEvent)
    if not eventTypeString then return end
    eventTypeString = eventTypeString .. "_SPELL_INTERRUPT"
    return eventTypeString, parserEvent.extraSkillName, affectedUnitName,
           affectedUnitClass
end

local function EnvironmentalHandler(parserEvent, currentProfile)
    if parserEvent.recipientUnit ~= "player" then return end
    return "INCOMING_ENVIRONMENTAL", parserEvent.hazardType
end

local function AuraHandler(parserEvent, currentProfile)
    local eventTypeString, affectedUnitName, affectedUnitClass
    local effectName = parserEvent.skillName
    if parserEvent.recipientUnit == "player" then
        if ignoreAuras[parserEvent.skillName] and parserEvent.sourceUnit ==
            "player" then return end
        if triggerSuppressions[effectName] then return end
        eventTypeString = "NOTIFICATION_" .. parserEvent.auraType
        if not parserEvent.isFade then
            if (parserEvent.isDose) then
                eventTypeString = eventTypeString .. "_STACK"
            end
        else
            eventTypeString = eventTypeString .. "_FADE"
        end
    else
        if triggerSuppressions[effectName] then return end
        if not TestFlagsAll(parserEvent.recipientFlags, MSBTParser.TARGET_TARGET) then
            return
        end
        if not UnitIsEnemy("player", "target") then return end
        if parserEvent.auraType ~= "BUFF" or parserEvent.isFade == true then
            return
        end
        local now = GetTime()
        for buff, cleanupTime in pairs(recentEnemyBuffs) do
            if (now >= cleanupTime) then recentEnemyBuffs[buff] = nil end
        end
        if recentEnemyBuffs[effectName] then return end
        recentEnemyBuffs[effectName] = now + ENEMY_BUFF_HOLD_TIME
        eventTypeString = "NOTIFICATION_ENEMY_BUFF"
        affectedUnitName = parserEvent.recipientName
        affectedUnitClass = classMap[parserEvent.recipientGUID]
    end
    return eventTypeString, effectName, affectedUnitName, affectedUnitClass
end

local function EnchantHandler(parserEvent, currentProfile)
    if parserEvent.recipientUnit ~= "player" then return end
    local eventTypeString = "NOTIFICATION_ITEM_BUFF"
    if parserEvent.isFade then eventTypeString = eventTypeString .. "_FADE" end
    return eventTypeString, parserEvent.skillName
end

local function DispelHandler(parserEvent, currentProfile)
    local eventTypeString
    if parserEvent.sourceUnit == "player" then
        eventTypeString = "OUTGOING_DISPEL"
    elseif parserEvent.sourceUnit == "pet" then
        eventTypeString = "PET_OUTGOING_DISPEL"
    else
        return
    end
    return eventTypeString, parserEvent.extraSkillName,
           parserEvent.recipientName, classMap[parserEvent.recipientGUID]
end

local function PowerHandler(parserEvent, currentProfile)
    if uniquePowerTypes[parserEvent.powerType] ~= nil then return end
    if currentProfile.showAllPowerGains then return end
    local amount
    if parserEvent.isLeech then
        if parserEvent.sourceUnit ~= "player" then return end
        amount = parserEvent.extraAmount
    else
        if parserEvent.recipientUnit ~= "player" then return end
        amount = parserEvent.amount
    end
    if amount == 0 then return end
    if amount and math_abs(amount) < currentProfile.powerThreshold then
        return
    end
    local eventTypePrefix = "NOTIFICATION_POWER_"
    if parserEvent.powerType == powerTypes["ALTERNATE_POWER"] then
        eventTypePrefix = "NOTIFICATION_ALT_POWER_"
    end
    local eventTypeString = eventTypePrefix ..
                                (parserEvent.isDrain and "LOSS" or "GAIN")
    return eventTypeString, parserEvent.skillName, nil, nil, true
end

local function KillHandler(parserEvent, currentProfile)
    if parserEvent.sourceUnit ~= "player" then return end
    if TestFlagsAll(parserEvent.recipientFlags, bit_bor(
                        MSBTParser.UNITTYPE_GUARDIAN, MSBTParser.CONTROL_HUMAN)) then
        return
    end
    if parserEvent.recipientUnit == "pet" then return end
    local eventTypeString = "NOTIFICATION_"
    eventTypeString = eventTypeString ..
                          (TestFlagsAll(parserEvent.recipientFlags,
                                        MSBTParser.CONTROL_SERVER) and "NPC" or
                              "PC")
    eventTypeString = eventTypeString .. "_KILLING_BLOW"
    return eventTypeString, nil, parserEvent.recipientName,
           classMap[parserEvent.recipientGUID]
end

local function HonorHandler(parserEvent, currentProfile)
    if parserEvent.recipientUnit ~= "player" then return end
    return "NOTIFICATION_HONOR_GAIN"
end

local function ReputationHandler(parserEvent, currentProfile)
    if parserEvent.recipientUnit ~= "player" then return end
    local eventTypeString = "NOTIFICATION_REP_" ..
                                (parserEvent.isLoss and "LOSS" or "GAIN")
    return eventTypeString, parserEvent.factionName
end

local function ProficiencyHandler(parserEvent, currentProfile)
    if parserEvent.recipientUnit ~= "player" then return end
    return "NOTIFICATION_SKILL_GAIN", parserEvent.skillName
end

local function ExperienceHandler(parserEvent, currentProfile)
    if parserEvent.recipientUnit ~= "player" then return end
    return "NOTIFICATION_EXPERIENCE_GAIN"
end

local function ExtraAttacksHandler(parserEvent, currentProfile)
    if parserEvent.sourceUnit ~= "player" then return end
    return "NOTIFICATION_EXTRA_ATTACK", parserEvent.skillName
end

local function ParserEventsHandler(parserEvent)
    -- -- DEBUG: What did we receive?
    -- print(string.format("HANDLER: eventType=%s amount=%s", 
        -- tostring(parserEvent.eventType),
        -- tostring(parserEvent.amount)))
    
    -- CRITICAL: Check if profile exists
    if not MSBTProfiles then
        -- print("HANDLER ERROR: MSBTProfiles is nil!")
        return
    end
    
    if not MSBTProfiles.currentProfile then
        -- print("HANDLER ERROR: currentProfile is nil!")
        return
    end
    
    -- print("HANDLER: Profile OK, continuing...")
    
    local currentProfile = MSBTProfiles.currentProfile
    local eventTypeString, effectName, affectedUnitName, affectedUnitClass, mergeEligible
    local eventType = parserEvent.eventType

    local handler = eventHandlers[eventType]
    -- print(string.format("HANDLER: handler exists=%s", tostring(handler ~= nil)))
    
    if handler then
        eventTypeString, effectName, affectedUnitName, affectedUnitClass, mergeEligible =
            handler(parserEvent, currentProfile)
        
        -- -- DEBUG: What did handler return?
        -- print(string.format("HANDLER RETURNS: eventTypeString=%s effectName=%s mergeEligible=%s", 
            -- tostring(eventTypeString),
            -- tostring(effectName),
            -- tostring(mergeEligible)))
    end
    
    if not eventTypeString then 
        -- print("HANDLER: eventTypeString is NIL - BLOCKING DISPLAY")
        return 
    end
    
    -- print("HANDLER: eventTypeString exists, continuing to display...")

    local isCrit = parserEvent.isCrit
    local eventSettings = currentProfile.events[isCrit and eventTypeString ..
                              "_CRIT" or eventTypeString]
    if not eventSettings or eventSettings.disabled or
        not IsScrollAreaActive(eventSettings.scrollArea) then return end

    local damageType = parserEvent.damageType
    local skillID = parserEvent.skillID
    if skillID == SPELLID_AUTOSHOT then
        skillID = nil;
        effectName = nil
    end
    local ignoreDamageColoring
    if eventType == "damage" and parserEvent.sourceUnit == "player" and
        damageType == DAMAGETYPE_PHYSICAL and skillID then
        ignoreDamageColoring = true
    end
    if eventType == "miss" and parserEvent.missType == "ABSORB" then
        damageType = parserEvent.skillSchool or DAMAGETYPE_PHYSICAL
    end

    local partialEffects
    if eventType == "damage" or eventType == "environmental" then
        partialEffects = FormatPartialEffects(parserEvent.absorbAmount,
                                              parserEvent.blockAmount,
                                              parserEvent.resistAmount,
                                              parserEvent.isGlancing,
                                              parserEvent.isCrushing)
    end

    local effectTexture
    if not currentProfile.skillIconsDisabled and
        IsScrollAreaIconShown(eventSettings.scrollArea) then
        if skillID then _, _, effectTexture = GetSpellInfo(skillID) end
        if (eventType == "dispel" or eventType == "interrupt" or
            (eventType == "miss" and parserEvent.missType == "RESIST")) and
            parserEvent.extraSkillID then
            _, _, effectTexture = GetSpellInfo(parserEvent.extraSkillID)
        end
        if not effectTexture and effectName then
            _, _, effectTexture = GetSpellInfo(effectName)
        end
    end

    if not mergeEligible then
        local outputMessage = FormatEvent(eventSettings.message,
                                          parserEvent.amount, damageType, nil,
                                          nil, nil, affectedUnitName,
                                          affectedUnitClass, effectName)
        DisplayEvent(eventSettings, outputMessage, effectTexture)
    elseif currentProfile.mergeExclusions[effectName] or
        (not effectName and currentProfile.mergeSwingsDisabled) then
        local hideSkills = effectTexture and
                               not currentProfile.exclusiveSkillsDisabled or
                               currentProfile.hideSkills
        local outputMessage = FormatEvent(eventSettings.message,
                                          parserEvent.amount, damageType,
                                          parserEvent.overhealAmount,
                                          parserEvent.overkillAmount,
                                          parserEvent.powerType,
                                          affectedUnitName, affectedUnitClass,
                                          effectName, partialEffects, nil,
                                          ignoreDamageColoring, hideSkills,
                                          currentProfile.hideNames)
        DisplayEvent(eventSettings, outputMessage, effectTexture)
    else
        local combatEvent = table_remove(combatEventCache) or {}
        if effectName and offHandTrailer and
            string_find(effectName, offHandTrailer, 1, true) then
            effectName = string_gsub(effectName, offHandPattern, "")
        end

        combatEvent.eventType = eventTypeString
        combatEvent.isCrit = isCrit
        combatEvent.amount = parserEvent.amount
        combatEvent.effectName = effectName
        combatEvent.effectTexture = effectTexture
        combatEvent.name = affectedUnitName
		combatEvent.mergeID = parserEvent.mergeID or "unknown"
        combatEvent.class = affectedUnitClass
        combatEvent.damageType = damageType
        combatEvent.ignoreDamageColoring = ignoreDamageColoring
        combatEvent.partialEffects = partialEffects
        combatEvent.overhealAmount = parserEvent.overhealAmount
        combatEvent.overkillAmount = parserEvent.overkillAmount
        combatEvent.powerType = parserEvent.powerType

        if effectName then
            local throttleDuration = currentProfile.throttleList[effectName]
            if not throttleDuration then
                if parserEvent.isDoT and currentProfile.dotThrottleDuration > 0 then
                    throttleDuration = currentProfile.dotThrottleDuration
                elseif parserEvent.isHoT and currentProfile.hotThrottleDuration >
                    0 then
                    throttleDuration = currentProfile.hotThrottleDuration
                elseif parserEvent.powerType and
                    currentProfile.powerThrottleDuration > 0 then
                    throttleDuration = currentProfile.powerThrottleDuration
                end
            end
            if throttleDuration and throttleDuration > 0 then
                local throttledAbility = throttledAbilities[effectName]
                if not throttledAbility then
                    throttledAbility = {}
                    throttledAbility.throttleWindow = 0
                    throttledAbility.lastEventTime = 0
                    throttledAbilities[effectName] = throttledAbility
                end
                local now = GetTime()
                if throttledAbility.throttleWindow > 0 then
                    throttledAbility.lastEventTime = now
                    throttledAbility[#throttledAbility + 1] = combatEvent
                    return
                else
                    throttledAbility.throttleWindow = throttleDuration
                    if not throttleFrame:IsVisible() then
                        throttleFrame:Show()
                    end
                    if now - throttledAbility.lastEventTime < throttleDuration then
                        throttledAbility.lastEventTime = now
                        throttledAbility[#throttledAbility + 1] = combatEvent
                        return
                    end
                end
            end
        end

        unmergedEvents[#unmergedEvents + 1] = combatEvent
        if not eventFrame:IsVisible() then eventFrame:Show() end
    end
end

local function OnUpdateEventFrame(this, elapsed)
    lastMergeUpdate = lastMergeUpdate + elapsed
    if lastMergeUpdate >= MERGE_DELAY_TIME then
        local currentProfile = MSBTProfiles.currentProfile
        local hideNames = currentProfile.hideNames
        local exclusiveSkillsDisabled = currentProfile.exclusiveSkillsDisabled

        MergeEvents(#unmergedEvents, currentProfile)

        local eventSettings, hideSkills, outputMessage
        for i, combatEvent in ipairs(mergedEvents) do
            eventSettings = currentProfile.events[combatEvent.isCrit and
                                combatEvent.eventType .. "_CRIT" or
                                combatEvent.eventType]
            hideSkills = combatEvent.effectTexture and
                             not exclusiveSkillsDisabled or
                             currentProfile.hideSkills
            outputMessage = FormatEvent(eventSettings.message,
                                        combatEvent.amount,
                                        combatEvent.damageType,
                                        combatEvent.overhealAmount,
                                        combatEvent.overkillAmount,
                                        combatEvent.powerType, combatEvent.name,
                                        combatEvent.class,
                                        combatEvent.effectName,
                                        combatEvent.partialEffects,
                                        combatEvent.mergeTrailer,
                                        combatEvent.ignoreDamageColoring,
                                        hideSkills, hideNames)
            DisplayEvent(eventSettings, outputMessage, combatEvent.effectTexture)
            mergedEvents[i] = nil
            EraseTable(combatEvent)
            combatEventCache[#combatEventCache + 1] = combatEvent
        end
        if #unmergedEvents == 0 then this:Hide() end
        lastMergeUpdate = 0
    end
end

local function OnUpdateThrottleFrame(this, elapsed)
    lastThrottleUpdate = lastThrottleUpdate + elapsed
    if lastThrottleUpdate >= THROTTLE_UPDATE_TIME then
        local eventsThrottled
        for _, throttledAbility in pairs(throttledAbilities) do
            if throttledAbility.throttleWindow > 0 then
                throttledAbility.throttleWindow =
                    throttledAbility.throttleWindow - lastThrottleUpdate
                if throttledAbility.throttleWindow <= 0 then
                    if #throttledAbility > 0 then
                        for i = 1, #throttledAbility do
                            unmergedEvents[#unmergedEvents + 1] =
                                throttledAbility[i]
                            throttledAbility[i] = nil
                        end
                        if not eventFrame:IsVisible() then
                            eventFrame:Show()
                        end
                    end
                else
                    eventsThrottled = true
                end
            end
        end
        if not eventsThrottled then this:Hide() end
        lastThrottleUpdate = 0
    end
end

function eventFrame:UNIT_POWER_UPDATE(unitID, powerToken)
    if unitID ~= "player" then return end
    local powerType = powerTypes[powerToken]
    if not powerType then return end
    local powerAmount = UnitPower("player", powerType)
    local doFullDetect = true
    local lastPowerAmount = lastPowerAmounts[powerType]

    if powerToken == "CHI" and playerClass == "MONK" then
        if powerAmount ~= lastPowerAmount then
            HandleChi(powerAmount, powerType)
        end
        doFullDetect = false
    elseif powerToken == "HOLY_POWER" and playerClass == "PALADIN" then
        if powerAmount ~= lastPowerAmount then
            HandleHolyPower(powerAmount, powerType)
        end
        doFullDetect = false
    elseif powerToken == "COMBO_POINTS" and playerClass == "ROGUE" then
        if powerAmount ~= lastPowerAmount then
            HandleComboPoints(powerAmount, powerType)
        end
        doFullDetect = false
    elseif powerToken == "COMBO_POINTS" and playerClass == "DRUID" then
        if powerAmount ~= lastPowerAmount then
            HandleComboPoints(powerAmount, powerType)
        end
        doFullDetect = false
    elseif powerToken == "ARCANE_CHARGES" and playerClass == "MAGE" then
        if powerAmount ~= lastPowerAmount then
            HandleArcanePower(powerAmount, powerType)
        end
        doFullDetect = false
    elseif powerToken == "ESSENCE" and playerClass == "EVOKER" then
        if powerAmount ~= lastPowerAmount then
            HandleEssence(powerAmount, powerType)
        end
        doFullDetect = false
    end

    if doFullDetect and MSBTProfiles.currentProfile.showAllPowerGains then
        DetectPowerGain(powerAmount, powerType)
    end
    lastPowerAmounts[powerType] = powerAmount
end

function eventFrame:PLAYER_REGEN_ENABLED()
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_COMBAT_LEAVE
    if not eventSettings.disabled then
        DisplayEvent(eventSettings, eventSettings.message)
    end
end

function eventFrame:PLAYER_REGEN_DISABLED()
    local eventSettings = MSBTProfiles.currentProfile.events
                              .NOTIFICATION_COMBAT_ENTER
    if not eventSettings.disabled then
        DisplayEvent(eventSettings, eventSettings.message)
    end
end

function eventFrame:CHAT_MSG_MONSTER_EMOTE(message, sourceName)
    if sourceName ~= UnitName("target") then return end
    HandleMonsterEmotes(string_gsub(message, "%%s", sourceName))
end

function eventFrame:UNIT_AURA(unitID, updateInfo)
    if unitID ~= "player" then return end
    if InCombatLockdown() then return end

    local currentProfile = MSBTProfiles.currentProfile
    if not currentProfile then return end

    if updateInfo.addedAuras then
        for _, auraData in pairs(updateInfo.addedAuras) do
            local success, name = pcall(function()
                if auraData.name and auraData.name ~= "" then
                    return auraData.name
                end
                return nil
            end)
            if success and name then
                activePlayerAuras[auraData.auraInstanceID] = {
                    name = name,
                    icon = auraData.icon,
                    isHelpful = auraData.isHelpful,
                    spellId = auraData.spellId
                }
                local auraType = auraData.isHelpful and "BUFF" or "DEBUFF"
                local eventSettings = currentProfile.events["NOTIFICATION_" ..
                                          auraType]
                if eventSettings and not eventSettings.disabled then
                    local message = eventSettings.message
                    local formattedName =
                        string_format("|cFF%02x%02x%02x%s|r",
                                      (eventSettings.colorR or 1) * 255,
                                      (eventSettings.colorG or 1) * 255,
                                      (eventSettings.colorB or 0) * 255, name)
                    message = string_gsub(message, "%%e", formattedName)
                    message = string_gsub(message, "%%sl", formattedName)
                    DisplayEvent(eventSettings, message, auraData.icon)
                end
            end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in pairs(updateInfo.removedAuraInstanceIDs) do
            local auraInfo = activePlayerAuras[auraInstanceID]
            if auraInfo then
                local auraType = auraInfo.isHelpful and "BUFF" or "DEBUFF"
                local eventSettings = currentProfile.events["NOTIFICATION_" ..
                                          auraType .. "_FADE"]
                if eventSettings and not eventSettings.disabled then
                    local message = eventSettings.message
                    local formattedName =
                        string_format("|cFF%02x%02x%02x%s|r",
                                      (eventSettings.colorR or 1) * 255,
                                      (eventSettings.colorG or 1) * 255,
                                      (eventSettings.colorB or 0) * 255,
                                      auraInfo.name)
                    message = string_gsub(message, "%%e", formattedName)
                    message = string_gsub(message, "%%sl", formattedName)
                    DisplayEvent(eventSettings, message, auraInfo.icon)
                end
                activePlayerAuras[auraInstanceID] = nil
            end
        end
    end
end

-- 12.0.1 SPECIAL HANDLERS
function eventFrame:CHAT_MSG_COMBAT_XP_GAIN(message)
    local mobName, amount = string_match(message,
                                         "(.*) dies, you gain (%d+) experience")
    if mobName then
        local kbSettings = MSBTProfiles.currentProfile.events
                               .NOTIFICATION_NPC_KILLING_BLOW
        if not kbSettings.disabled then
            local output = FormatEvent(kbSettings.message, nil, nil, nil, nil,
                                       nil, mobName, nil, nil)
            DisplayEvent(kbSettings, output)
        end
    end
    if not amount then amount = string_match(message, "gain (%d+)") end
    if amount then
        local xpSettings = MSBTProfiles.currentProfile.events
                               .NOTIFICATION_EXPERIENCE_GAIN
        if not xpSettings.disabled then
            local output = FormatEvent(xpSettings.message, tonumber(amount))
            DisplayEvent(xpSettings, output)
        end
    end
end

function eventFrame:CHAT_MSG_COMBAT_FACTION_CHANGE(message)
    local faction, amount
    faction, amount = string_match(message, PATTERN_REP_INC)
    if faction and amount then
        local eventSettings = MSBTProfiles.currentProfile.events
                                  .NOTIFICATION_REP_GAIN
        if not eventSettings.disabled then
            local output = FormatEvent(eventSettings.message, tonumber(amount),
                                       nil, nil, nil, nil, nil, nil, faction)
            DisplayEvent(eventSettings, output)
        end
        return
    end
    faction, amount = string_match(message, PATTERN_REP_DEC)
    if faction and amount then
        local eventSettings = MSBTProfiles.currentProfile.events
                                  .NOTIFICATION_REP_LOSS
        if not eventSettings.disabled then
            local output = FormatEvent(eventSettings.message, tonumber(amount),
                                       nil, nil, nil, nil, nil, nil, faction)
            DisplayEvent(eventSettings, output)
        end
    end
end

function eventFrame:UNIT_SPELLCAST_INTERRUPTED(unit, castGUID, spellID)
    if unit == "target" or unit == "focus" then
        local targetName = UnitName(unit)
        local eventSettings = MSBTProfiles.currentProfile.events
                                  .OUTGOING_SPELL_INTERRUPT
        if not eventSettings.disabled then
            local output = FormatEvent(eventSettings.message, nil, nil, nil,
                                       nil, nil, targetName, nil, targetName)
            DisplayEvent(eventSettings, output)
        end
    end
end

function eventFrame:UNIT_COMBAT(unit, action, descriptor, amount, damageType)
    if unit == "player" then
        if action == "WOUND" and (descriptor == nil or descriptor == "") then
            if (GetTime() - lastFallTime) < 0.5 then
                local dmg = tonumber(amount)
                if dmg then
                    local envSettings = MSBTProfiles.currentProfile.events
                                            .INCOMING_ENVIRONMENTAL
                    if not envSettings.disabled then
                        local output = FormatEvent(envSettings.message, dmg,
                                                   nil, nil, nil, nil, nil, nil,
                                                   "Falling")
                        DisplayEvent(envSettings, output)
                    end
                end
            end
        end
        if action == "ENVIRONMENTAL" or action == "FALLING" then
            local dmg = tonumber(amount)
            if dmg then
                local envSettings = MSBTProfiles.currentProfile.events
                                        .INCOMING_ENVIRONMENTAL
                if not envSettings.disabled then
                    local output = FormatEvent(envSettings.message, dmg, nil,
                                               nil, nil, nil, nil, nil,
                                               "Falling")
                    DisplayEvent(envSettings, output)
                end
            end
        end
    end
end

local function Enable()
    eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
    eventFrame:RegisterEvent("UNIT_AURA")

    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target", "focus")
    eventFrame:RegisterUnitEvent("UNIT_COMBAT", "player")

    MSBTParser.RegisterHandler(ParserEventsHandler)
end

local function Show12_0_1Notice()
    C_Timer.After(5, function()
        MikSBT.Print(
            "|cFFFFD700MSBT 12.0.1 Notice:|r Buff/debuff notifications are unavailable in combat due to Blizzard API restrictions. All damage, healing, and other combat text features are working normally.",
            1, 0.82, 0)
    end)
end

local function Disable()
    eventFrame:Hide()
    eventFrame:UnregisterAllEvents()
    MSBTParser.UnregisterHandler(ParserEventsHandler)
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------
eventFrame:Hide()
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if self[event] then self[event](self, ...) end
end)
eventFrame:SetScript("OnUpdate", OnUpdateEventFrame)

throttleFrame:Hide()
throttleFrame:SetScript("OnUpdate", OnUpdateThrottleFrame)

_, playerClass = UnitClass("player")

eventHandlers["damage"] = DamageHandler
eventHandlers["miss"] = MissHandler
eventHandlers["heal"] = HealHandler
eventHandlers["interrupt"] = InterruptHandler
eventHandlers["environmental"] = EnvironmentalHandler
eventHandlers["aura"] = AuraHandler
eventHandlers["enchant"] = EnchantHandler
eventHandlers["dispel"] = DispelHandler
eventHandlers["power"] = PowerHandler
eventHandlers["kill"] = KillHandler
eventHandlers["honor"] = HonorHandler
eventHandlers["reputation"] = ReputationHandler
eventHandlers["proficiency"] = ProficiencyHandler
eventHandlers["experience"] = ExperienceHandler
eventHandlers["extraattacks"] = ExtraAttacksHandler

for powerToken, powerType in pairs(powerTypes) do
    powerTokens[powerType] = powerToken
end

uniquePowerTypes[Enum.PowerType.HolyPower] = true
uniquePowerTypes[Enum.PowerType.Chi] = true
uniquePowerTypes[Enum.PowerType.ComboPoints] = true
uniquePowerTypes[Enum.PowerType.ArcaneCharges] = true

CreateDamageMaps()

if string_find(GetLocale(), "en..") then isEnglish = true end

ignoreAuras[SPELL_BLINK] = true
ignoreAuras[SPELL_RAIN_OF_FIRE] = true

if type(SPELL_BLOOD_STRIKE) == "string" and SPELL_BLOOD_STRIKE ~= UNKNOWN then
    offHandPattern = string.gsub(SPELL_BLOOD_STRIKE, "([%^%(%)%.%[%]%*%+%-%?])",
                                 "%%%1")
end

module.damageTypeMap = damageTypeMap
module.damageColorProfileEntries = damageColorProfileEntries
module.Enable = Enable
module.Disable = Disable
module.Show12_0_1Notice = Show12_0_1Notice

MikSBT.DISPLAYTYPE_INCOMING = "Incoming"
MikSBT.DISPLAYTYPE_OUTGOING = "Outgoing"
MikSBT.DISPLAYTYPE_NOTIFICATION = "Notification"
MikSBT.DISPLAYTYPE_STATIC = "Static"

MikSBT.RegisterFont = MSBTMedia.RegisterFont
MikSBT.RegisterAnimationStyle = MSBTAnimations.RegisterAnimationStyle
MikSBT.RegisterStickyAnimationStyle =
    MSBTAnimations.RegisterStickyAnimationStyle
MikSBT.RegisterSound = MSBTMedia.RegisterSound
MikSBT.IterateFonts = MSBTMedia.IterateFonts
MikSBT.IterateScrollAreas = MSBTAnimations.IterateScrollAreas
MikSBT.IterateSounds = MSBTMedia.IterateSounds
MikSBT.DisplayMessage = MSBTAnimations.DisplayMessage
MikSBT.IsModDisabled = MSBTProfiles.IsModDisabled
