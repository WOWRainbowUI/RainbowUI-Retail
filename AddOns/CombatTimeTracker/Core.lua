-- Declare AceAddon
CTT = LibStub("AceAddon-3.0"):NewAddon("CTT", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("cttTranslations")


--|-------------------------|
--| Variable Declarations   |
--|-------------------------|

local isTBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local zone = GetRealZoneText()
local profileList = {}
local newProfileName = ""
local time = 0
local fontTableOptions = {}
local soundTableOptions = {}
local bossEncounter = false
local bossEncounterName = ""
local lastBossSoundPlayed = ""
local loadOptionsAfterCombat = false
local hours = "00"
local minutes = "00"
local seconds = "00"
local totalSeconds = "00"
local miliseconds = "00"
local fontDropDownMorpheus = 0
local cttElapsedSeconds = 0
local globalMenu

local defaults = {
    profile = {
        minimap = {
            hide = false,
        },
        RaidKills = {},
        cttMenuOptions = {
            soundName = "",
            instanceType = 4,
            textFrameSizeSlider = 1,
            timeValues = { "00", "00", "00", "00", "00" },
            raidKey = 1,
            alerts = {},
            difficultyDropDown = 2,
            raidDropdown = "Castle Nathria",
            textColorPicker = { 255, 255, 255, 1 },
            fontVal = 32,
            localStore = "",
            toggleTarget = true,
            fontName = "Fonts\\bLEI00D.ttf",
            dropdownValue = 2, -- 文字格式
            dropdownValue2 = 1,
            dropdownValue3 = 1,
            soundDropDownValue = 1,
            lockFrameCheckButton = false,
            bossDropdown = "Shriekwing",
            bossDropDownkey = 1,
            backDropAlphaSlider = 1,
            timeTrackerSize = { 200, 80 },
            uiReset = false,
            lastVersion = "test",
            togglePrint = true,
            cttTextFormatOptions = { "(SS)", "(MM:SS)", "(HH:MM:SS)", "(MM:SS.MS)", "(MM:SS:MS)" },
            framePoint = "CENTER",
            frameRelativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
            fontFlags = "",
            textFlags = false,
            xpacKey = 1,
            expansion = "Classic",
            resetCounterOnEndOfCombat = true,
            selectedTab = "options",
            clickThrough = true
        }
    }
}

local xpacs = {
    L["Classic"],
    L["Burning Crusade"],
    -- "Wrath of the Lich King",
    -- "Cataclysm",
    -- "Mists of Pandaria",
    -- "Warlords of Draenor",
    -- "Legion",
    -- "Battle for Azeroth",
    L["Shadowlands"],
	L["DragonFlight"],
	L["The War Within"]
}

local raidInstanceZones = {
    --Classic
    {
        "Blackwing Lair",
        "Molten Core",
        "Ruins of Ahn'Qiraj",
        "Temple of Ahn'Qiraj"
    },
    --TBC
    {
        "Karazhan",
        "Guul's Lair",
        "Magtheridon's Lair",
        "Serpentshrine Cavern",
        "The Eye",
        "The Battle for Mount Hyjal",
        "Black Temple",
        "Sunwell Plateau"
    },
    -- SL
    {
        L["Castle Nathria"],
        L["Sanctum of Domination"],
        L["Sepulcher of the First Ones"]
    },
	 -- DF
    {
        L["Vault of the Incarnates"],
        L["Aberrus, the Shadowed Crucible"],
        L["Amirdrassil, the Dream's Hope"]
    },
    -- TWW
    {
        L["Nerub-ar Palace"],
        L["Liberation of Undermine"]
    }
}

local raidBosses = {
    -- Classic
    {
        -- Blackwing Lair
        {
            "Razorgore the Untamed",
            "Vaelastrasz the Corrupt",
            "Broodlord Lashlayer",
            "Firemaw",
            "Ebonroc",
            "Flamegor",
            "Chromaggus",
            "Nefarian"
        },
        -- Molten Core
        {
            "Lucifron",
            "Magmadar",
            "Gehennas",
            "Garr",
            "Shazzrah",
            "Baron Geddon",
            "Sulfuron Harbinger",
            "Golemagg the Incinerator",
            "Majordomo Executus",
            "Ragnaros"
        },
        -- Ruins of Ahn'Qiraj
        {
            "Kurinnaxx",
            "General Rajaxx",
            "Moam",
            "Buru the Gorger",
            "Ayamiss the Hunter",
            "Ossirian the Unscarred"
        },
        -- Temple of Ahn'Qiraj
        {
            "The Prophet Skeram",
            "Silithid Royalty",
            "Battleguard Sartura",
            "Fankriss the Unyielding",
            "Viscidus",
            "Princess Huhuran",
            "The Twin Emperors",
            "Ouro",
            "C'Thun"
        }
    },
    -- Burning Crusade
    {
        -- Karazhan
        {
            "Attumen the Huntsman",
            "Moroes",
            "Maiden of Virtue",
            "Opera Hall",
            "The Curator",
            "Shade of Aran",
            "Terestian Illhoof",
            "Netherspite",
            "Chess Event",
            "Prince Malchezaar",
            "Nightbane"
        },
        -- Gruul's Lair
        {
            "High Kind Maulgar",
            "Gruul the Dragonkiller"
        },
        -- Magtheridon's Lair
        {
            "Magtheridon"
        },
        -- Serpentshrine Cavern
        {
            "Hydross the Unstable",
            "The Lurker Below",
            "Leotheras the Blind",
            "Fathom-Lord Karathress",
            "Morogrim Tidewalker",
            "Lady Vashj"
        },
        -- The Eye
        {
            "Al'ar",
            "Void Reaver",
            "High Astromancer Solarian",
            "Kael'thas Sunstrider"
        },
        -- The battle for mount hyjal
        {
            "Rage Winterchill",
            "Anetheron",
            "Kaz'rogal",
            "Azgalor",
            "Archimonde"
        },
        -- Black Temple
        {
            "High Warlord Naj'entus",
            "Supremus",
            "Shade of Akama",
            "Teron Gorefiend",
            "Gurtogg Bloodboil",
            "Reliquary of Souls",
            "Mother Shahraz",
            "The Illidari Council",
            "Illidan Stormrage"
        },
        -- Sunwell Plateau
        {
            "Kalecgos",
            "Brutallus",
            "Felmyst",
            "The Eredar Twins",
            "M'uru",
            "Kil'jaedon"
        }
    },
    -- Shadowlands
    {
        -- CN
        {
            L["Shriekwing"],
            L["Huntsman Altimor"],
            L["Sun King's Salvation"],
            L["Artificer Xy'mox"],
            L["Hungering Destroyer"],
            L["Lady Inerva Darkvein"],
            L["The Council of Blood"],
            L["Sludgefist"],
            L["Stone Legion Generals"],
            L["Sire Denathrius"]
        },
        -- SOD
        {
            L["The Tarragrue"],
            L["The Eye of the Jailer"],
            L["The Nine"],
            L["Remnat of Ner'zhul"],
            L["Soulrender Dormazain"],
            L["Painsmith Raznal"],
            L["Guardian of the First Ones"],
            L["Fatescribe Roh-Kalo"],
            L["Kel'Thuzad"],
            L["Sylvanas Windrunner"]
        },
        -- SOFTO
        {
            L["Vigilant Guardian"],
            L["Skolex, the Insatiable Ravener"],
            L["Artificer Xy'mox"],
            L["Dausegne, the Fallen Oracle"],
            L["Prototype Pantheon"],
            L["Lihuvim, Principal Architect"],
            L["Halondrus the Reclaimer"],
            L["Anduin Wrynn"],
            L["Lords of Dread"],
            L["Rygelon"],
            L["The Jailer"]
        }
    },
    -- DF
    {
        -- Vault
        {
            "Eranog",
            "Terros",
            "The Prime council",
            "Sennarth, the Cold Breath",
            "Dathea, Ascended",
            "Kurog Grimtotem",
            "Broodkeeper Diurna",
            "Raszageth the Storm-Eater"
        },
        -- Aberrus
        {
            "Kazzara, the Hellforged",
            "The Amalgamation chamber",
            "The Forgotten Experiments",
            "Assault of the Zaqali",
            "Rashok, the Elder",
            "The Vigilent Steward, Zskarn",
            "Echo of Neltharion",
            "Scalecommander Sarkareth"
        },
        -- Amirdrassil
        {
            "Gnarlroot",
            "Igira the Cruel",
            "Volcoross",
            "Council of Dreams",
            "Larodar, Keeper of the Flame",
            "Nymue, Weaver of the Cycle",
            "Smolderon",
            "Tindral Sageswift, Seer of the Flame",
            "Fyrakk the Blazing"
        }
    },
    -- TWW
    {
        --  Nerub-ar Palace
        {
            "Ulgrax the Devourer",
            "The Bloodbound Horror",
            "Sikran, Captain of the Sureki",
            "Rasha'nan",
            "Broodtwister Ovi'nax",
            "Nexus-Princess Ky'veza",
            "The Silken Court",
            "Queen Ansurek"
        },
        -- Liberation of Undermine
        {
            "Vexie and the Geargrinders",
            "Cauldron of Carnage",
            "Rik Reverb",
            "Stix Bunkjunker",
            "Sprocketmonger Lockenstock",
            "The One-Armed Bandit",
            "Mug'Zee, Heads of Security",
            "Chrome King Gallywix"
        }
    }
}

local raidEncounterIDs = {
    -- Classic
    {
        -- BL
        {
            610, 611, 612, 613, 614, 615, 616, 617
        },
        -- MC
        {
            663, 664, 665, 666, 667, 668, 669, 670, 671, 672
        },
        -- RoAQ
        {
            718, 719, 720, 721, 722, 723
        },
        -- ToAQ
        {
            709, 710, 711, 712, 713, 714, 715, 716, 717
        }
    },
    -- TBC
    {
        -- Kara
        {
            652, 653, 654, 655, 656, 658, 657, 659, 660, 661, 662
        },
        -- Gruuls Lair
        {
            649, 650
        },
        -- Magtheridon's Lair
        {
            651
        },
        -- Serpenshrine Cavern
        {
            623, 624, 625, 626, 627, 628
        },
        -- The Eye
        {
            730, 731, 732, 733
        },
        -- The Battle for Mount Hyjal
        {
            618, 619, 620, 621, 622
        },
        -- Black Temple
        {
            601, 602, 603, 604, 605, 606, 607, 608, 609
        },
        -- Sunwell Plateau
        {
            724, 725, 726, 727, 728, 729
        }
    },
    -- SL
    {
        -- Castle Nathria
        {
            2398, 2418, 2402, 2405, 2383, 2406, 2412, 2399, 2417, 2407
        },
        -- Sanctum Of Domination
        {
            2423, 2433, 2429, 2432, 2434, 2430, 2436, 2431, 2422, 2435
        },
        -- Sepulchar of the First Ones
        {
            2512, 2542, 2553, 2540, 2544, 2539, 2529, 2546, 2543, 2549, 2537
        }
    },
    -- DF
    {
        -- Vault of the Incarnates
        {
            2587, 2639, 2590, 2592, 2635, 2605, 2614, 2607
        },
        -- Aberrus, the Shadowed Crucible
        {
            2688, 2687, 2693, 2682, 2680, 2689, 2683, 2684, 2685
        },
        -- Amirdrassil, the Dream's Hope
        {
            2820, 2709, 2737, 2728, 2731, 2708, 2824, 2786, 2677
        }
    },
    -- TWW
    {
        -- Nerub-ar Palance
        {
            2902, 2917, 2898, 2918, 2919, 2920, 2921, 2922
        },
        -- Liberation of Undermine
        {
            3009, 3010, 3011, 3012, 3013, 3014, 3015, 3016
        }
    }
}

local instanceTypes = {
    L["Dungeons Only"], 
    L["Raids Only"],
    L["Dungons and Raids Only"], 
    L["Everywhere"],
    L["Combat Only"]
}

local instanceZones = {
    "De Other Side",
    "Halls of Atonement",
    "Miss of Tirna Scithe",
    "Plaguefall",
    "Sanguine Depths",
    "Spires of Ascension",
    "The Necrotic Wake",
    "Theater of Pain",
    "Tazavesh, the Veiled Market",
    "Blackfathom Deeps",
    "Blackrock Depths",
    "Deadmines",
    "Dire Maul",
    "Gnomeregan",
    "Lower Blackrock Spire",
    "Maraudon",
    "Ragefire Chasm",
    "Razorfen Downs",
    "Razorfen Kraul",
    "Scarlet Halls",
    "Scarlet Monastery",
    "Scholomance",
    "Shadowfang Keep",
    "Stratholme",
    "The Stockade",
    "The Temple of Atal'hakkar",
    "Uldaman",
    "Wailing Caverns",
    "Zul'Farrak",
    "Auchenai Crypts",
    "Hellfire Ramparts",
    "Magisters' Terrace",
    "Mana-Tombs",
    "Old Hillsbrad Foothills",
    "Sethekk Halls",
    "The Arcatraz",
    "The Black Morass",
    "The Blood Furnace",
    "The Botanica",
    "The Mechanar",
    "The Shattered Halls",
    "The Slave Pens",
    "The Steamvault",
    "The Underbog",
    "Ara-Kara, City of Echoes",
    "Cinderbrew Meadery",
    "City of Threads",
    "Darkflame Cleft",
    "Priory of the Sacred Flame",
    "The Dawnbreaker",
    "The Stonevault",
    "Operation: Floodgate",
    "Theater of Pain",
    "Operation: Mechagon",
    "The MOTHERLODE!!",
    "The Necrotic Wake",
    "Mists of Tirna Scithe",
    "Siege of Boralus",
    "Grim Batol"
}

local backdropSettings = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
    tile = true,
    tileSize = 16
}

local NonHearthstones = {
    "Autographed Hearthstone Card",
    "Hearthstone Board"
}


--|----------------------------|
--| Ace Library Declarations   |
--|----------------------------|

local AceGUI = LibStub("AceGUI-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local db
local icon = LibStub("LibDBIcon-1.0")
local cttLBD = LibStub("LibDataBroker-1.1"):NewDataObject("CombatTimeTracker", {
    type = "data source",
    text = L["Combat Time Tracker"],
    icon = "Interface\\Icons\\inv_belt_armor_waistoftime_d_01",
    OnClick = function(button, buttonPressed)
        if buttonPressed == "RightButton" then
            if db.minimap and db.minimap.lock then -- 暫時修正
                icon:Unlock("CombatTimeTracker")
            else
                icon:Lock("CombatTimeTracker")
            end
        elseif buttonPressed == "MiddleButton" then
            icon:Hide("CombatTimeTracker")
            if (db.minimap == nil) then
                db.minimap = {
                    hide = true,
                }
            end
            db.profile.cttMenuOptions.minimapIconCheckButton = true
        else
            CTT_ToggleMenu()
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        tooltip:AddLine(L["|cffff930fCombat Time Tracker|r"])
        tooltip:AddLine(L["Click to open Options Menu"])
        tooltip:AddLine(L["Middle-Click to hide minimap Button"])
        tooltip:AddLine(L["Right-click to lock Minimap Button"])
    end,
})


--|----------------------|
--| AceAddon Functions   |
--|----------------------|

function CTT:OnEnable()
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("ENCOUNTER_START", "Encounter_Start")
    self:RegisterEvent("ENCOUNTER_END", "Encounter_End")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("CHALLENGE_MODE_START")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("CHALLENGE_MODE_RESET")
end

-- Register slash commands for addon.
function CTT:OnInitialize()
    self:RegisterChatCommand('ctt', 'SlashCommands')
    LSM.RegisterCallback(self, "LibSharedMedia_Registered", "UpdateUsedMedia")
    db = LibStub("AceDB-3.0"):New("cttDB", defaults)
    icon:Register("CombatTimeTracker", cttLBD, db.minimap)
    if not db.profile.minimap.hide then
        icon:Show("CombatTimeTracker")
    end

    if activeProfile == nil and activeProfileKey == nil then
        db:SetProfile(UnitName("player") .. ' - ' .. GetRealmName())
        for k, v in ipairs(db:GetProfiles()) do
            if v == UnitName("player") .. ' - ' .. GetRealmName() then
                activeProfile = v
                activeProfileKey = k
            end
        end
    end

    db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

-- Handle profile callbacks
function CTT:RefreshConfig()
    CTT_SetTrackerSizeOnLogin()
    CTT_UpdateText(db.profile.cttMenuOptions.timeValues[1], db.profile.cttMenuOptions.timeValues[2],
        db.profile.cttMenuOptions.timeValues[3], db.profile.cttMenuOptions.timeValues[5],
        db.profile.cttMenuOptions.dropdownValue, 1)
    for k, v in ipairs(db:GetProfiles()) do
        if activeProfile == v and activeProfileKey ~= nil and activeProfile ~= nil then
            activeProfileKey = k
        end
    end
end

-- Handle the initialization of values from nil to 0 first time addon is loaded.
function CTT:ADDON_LOADED()
    if longestMin == nil then
        longestMin = 0
    end

    if longestSec == nil then
        longestSec = 0
    end

    if db.profile.RaidKills == nil then
        db.profile.RaidKills = {}
    end

    if db.profile.cttMenuOptions.selectedTab ~= nil and db.profile.cttMenuOptions.selectedTab ~= "options" then
        db.profile.cttMenuOptions.selectedTab = "options"
    end

    CTT_CheckForReload()
    if C_AddOns.GetAddOnMetadata("CombatTimeTracker", "Version") >= db.profile.cttMenuOptions.lastVersion and
        db.profile.cttMenuOptions.uiReset then
        CTT_PopUpMessage()
    end

    cttStopwatchGui.elapsed = .05
    cttStopwatchGui:SetScript("OnUpdate", function(self, elapsed)
        cttElapsedSeconds = cttElapsedSeconds + elapsed
        self.elapsed = self.elapsed - elapsed
        if self.elapsed > 0 then return end
        self.elapsed = 0.05
        -- rest of the code here
        -- print(cttStopwatchGuiTargetText:GetText())
        if UnitAffectingCombat("player") or bossEncounter or not db.profile.cttMenuOptions.resetCounterOnEndOfCombat then
            --CTT:Print(cttElapsedSeconds)
            CTT_CheckForTarget()
            local times = GetTime() - time
            local time = cttElapsedSeconds
            totalSeconds = floor(time)
            hours = floor(time / 3600)
            minutes = floor((time - floor(time / 3600) * 3600) / 60)
            seconds = floor(time - floor(time / 3600) * 3600 - floor((time - floor(time / 3600) * 3600) / 60) * 60)
            miliseconds = floor((
                time - floor(time / 3600) * 3600 - floor((time - floor(time / 3600) * 3600) / 60) * 60 -
                    floor(time - floor(time / 3600) * 3600 - floor((time - floor(time / 3600) * 3600) / 60) * 60)) * 100)

            if seconds < 10 then
                --local temp = tostring(seconds)
                seconds = "0" .. seconds
            end
            if minutes < 10 then
                --local temp = tostring(minutes)
                minutes = "0" .. minutes
            end
            if hours < 10 then
                --local temp = tostring(hours)
                hours = "0" .. hours
            end
            if totalSeconds < 10 then
                --local temp = tostring(totalSeconds)
                totalSeconds = "0" .. totalSeconds
            end
            if miliseconds < 10 then
                miliseconds = "0" .. miliseconds
            end

            --db.profile.cttMenuOptions.timeValues = {hours, minutes, seconds, tonumber(string.format("%02.f", math.floor(times)))}
            CTT_UpdateText(hours, minutes, seconds, miliseconds, db.profile.cttMenuOptions.dropdownValue, 1)
            if (lastBossSoundPlayed ~= totalSeconds) then
                CTT_CheckToPlaySound()
            end
        end
    end)
end

-- Handle the stopwatch when entering combat.
function CTT:PLAYER_REGEN_DISABLED()
    if db.profile.cttMenuOptions.instanceType == 5 and (not cttStopwatchGui:IsShown()) then cttStopwatchGui:Show() end
    if not bossEncounter then
        if db.profile.cttMenuOptions.resetCounterOnEndOfCombat then
            time = GetTime()
            cttElapsedSeconds = 0
        end
        CTT_InstanceTypeDisplay(db.profile.cttMenuOptions.instanceType)
        --self:Print(L["Entering Combat!"])
    else
        return
    end
end

-- Handle the stopwatch when leaving combat.
function CTT:PLAYER_REGEN_ENABLED()
    if db.profile.cttMenuOptions.instanceType == 5 and cttStopwatchGui:IsShown() then cttStopwatchGui:Hide() end
    if not bossEncounter then
        if loadOptionsAfterCombat then
            CTT_ToggleMenu()
            loadOptionsAfterCombat = false
        end
        --self:Print(L["Leaving Combat!"])
        db.profile.cttMenuOptions.timeValues = { hours, minutes, seconds, totalSeconds, miliseconds }
        local min = 0
        local sec = 0
        local temp = GetTime() - time
        local tempSec = temp % 60
        if tempSec > 0 then
            sec = tonumber(math.floor(tempSec))
        end
        min = tonumber(string.format("%02.f", math.floor(temp / 60)))

        if sec < 10 then
            local temp = tostring(sec)
            sec = "0" .. temp
        end
        if min < 10 then
            local temp = tostring(min)
            min = "0" .. temp
        end
        if tonumber(min) > longestMin then
            longestMin = tonumber(min)
            longestSec = tonumber(sec)
            CTT_DisplayResults(true)
        elseif tonumber(min) == longestMin then
            if tonumber(sec) > longestSec then
                longestMin = tonumber(min)
                longestSec = tonumber(sec)
                CTT_DisplayResults(true)
            else
                CTT_DisplayResults(false)
            end
        else
            CTT_DisplayResults(false)
        end
    else
        return
    end
end

-- Hook function into ENCOUNTER_START to handle getting the data stored.
function CTT:Encounter_Start(...)
    if db.profile.cttMenuOptions.instanceType == 5 and not cttStopwatchGui:IsShown() then cttStopwatchGui:Show() end
    bossEncounter = true
    local eventName, encounterID, encounterName, difficultyID, groupSize = ...

    bossEncounterName = encounterID
    --CTT:Print(L["Encounter Started!"])
    -- local members = {}
    -- local numMembers = GetNumGroupMembers()
    -- if numMembers > 1 then
    --     for i=1,GetNumGroupMembers(),1 do
    --         members[i] = select(1, GetRaidRosterInfo(i))
    --     end
    -- else
    --     members = {UnitName("player")}
    -- end

    if db.profile.cttMenuOptions.resetCounterOnEndOfCombat then
        time = GetTime()
        cttElapsedSeconds = 0
    end
    CTT_InstanceTypeDisplay(db.profile.cttMenuOptions.instanceType)
end

-- Hook function into ENOUNTER_END to handle storing the data after a fight ends.
function CTT:Encounter_End(...)
    if db.profile.cttMenuOptions.instanceType == 5 and cttStopwatchGui:IsShown() then cttStopwatchGui:Hide() end
    bossEncounter = false
    bossEncounterName = ""
    if loadOptionsAfterCombat then
        loadOptionsAfterCombat = false
        CTT_ToggleMenu()
    end
    --CTT:Print(L["Encounter Ended!"])
    local eventName, encounterID, encounterName, difficultyID, groupSize, success = ...

    local xpacValue = CTT_GetExpansionByEncounterId(encounterID)
    local raidValue = CTT_GetRaidByZoneText()
    local difficultyValue = CTT_GetDifficultyById(difficultyID)

    if success == 1 then
        CTT_StoreBossKills(xpacValue, raidValue, encounterName, groupSize, difficultyValue, true)
        CTT_DisplayResultsBosses(encounterName, true)
    else
        CTT_DisplayResultsBosses(encounterName, false)
        CTT_StoreBossKills(xpacValue, raidValue, encounterName, groupSize, difficultyValue, false)
    end
end

-- event function for knowing when a m+ dungeon ends
function CTT:CHALLENGE_MODE_COMPLETED()
end

-- event function to handle starting m+ dungeon
function CTT:CHALLENGE_MODE_START(mapID)
    if db.profile.cttMenuOptions.resetCounterOnEndOfCombat then
        time = GetTime()
    end
end

function CTT:COMBAT_LOG_EVENT_UNFILTERED()
    local playerGUID = UnitGUID("player")
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand =
        CombatLogGetCurrentEventInfo()

    if sourceGUID == playerGUID and subevent == "SPELL_CAST_SUCCESS" and
        not CTT_TableContainsValue(NonHearthstones, spellName) and
        string.find(spellName, "Hearthstone") then
        ResetInstances();
    end
end

function CTT:CHALLENGE_MODE_RESET(mapID)

end

-- event function to handle persistence on the settings of the tracker when the player enters the world
function CTT:PLAYER_ENTERING_WORLD()
    -- CTT:Print("player entering world")
    CTT_InstanceTypeDisplay(db.profile.cttMenuOptions.instanceType)
    if db.profile.cttMenuOptions.timeTrackerSize then
        CTT_SetTrackerSizeOnLogin()
    end
    if db.profile.cttMenuOptions.lockFrameCheckButton then
        cttStopwatchGui:EnableMouse(false)
    else
        cttStopwatchGui:EnableMouse(true)
    end
    if db.profile.cttMenuOptions.timeValues then
        hours = db.profile.cttMenuOptions.timeValues[1]
        minutes = db.profile.cttMenuOptions.timeValues[2]
        seconds = db.profile.cttMenuOptions.timeValues[3]
        totalSeconds = db.profile.cttMenuOptions.timeValues[4]
        miliseconds = db.profile.cttMenuOptions.timeValues[5]
        CTT_UpdateText(db.profile.cttMenuOptions.timeValues[1], db.profile.cttMenuOptions.timeValues[2],
            db.profile.cttMenuOptions.timeValues[3], db.profile.cttMenuOptions.timeValues[5],
            db.profile.cttMenuOptions.dropdownValue, 1)
    else
        CTT_UpdateText("00", "00", "00", "00", 1, 1)
    end

    cttStopwatchGui:SetScript("OnDragStart", function(self)
        if not self.isMoving then
            self:StartMoving();
            self.isMoving = true;
        end
    end)

    cttStopwatchGui:SetScript("OnDragStop", function(self)
        if self.isMoving then
            self:StopMovingOrSizing();
            self.isMoving = false;
            -- print(cttStopwatchGui:GetPoint(1))
            local point, relativeTo, relativePoint, xOfs, yOfs = cttStopwatchGui:GetPoint()
            db.profile.cttMenuOptions.framePoint = point
            db.profile.cttMenuOptions.frameRelativePoint = relativePoint
            db.profile.cttMenuOptions.xOfs = xOfs
            db.profile.cttMenuOptions.yOfs = yOfs
        end
    end)
end

function CTT:ZONE_CHANGED()
    --[==[@debug@
    ---self:Print("Zone_Changed: " .. GetRealZoneText())
    --self:Print("Zone_Changed: " .. GetSubZoneText())
    --@end-debug@]==]
end

function CTT:ZONE_CHANGED_INDOORS()
    --[==[@debug@
    --self:Print("Zone_Changed_Indoors: " .. GetRealZoneText())
    --self:Print("Zone_Changed_Indoors: " .. GetSubZoneText())
    --@end-debug@]==]
end

function CTT:ZONE_CHANGED_NEW_AREA()
    --[==[@debug@
    --self:Print("Zone_Changed_New_Area: " .. GetRealZoneText())
    --self:Print("Zone_Changed_New_Area: " .. GetSubZoneText())
    --@end-debug@]==]

    zone = GetRealZoneText()
    CTT_InstanceTypeDisplay(db.profile.cttMenuOptions.instanceType)
end

-- Handle Player Target Swaps
function CTT:PLAYER_TARGET_CHANGED()
    CTT_CheckForTarget()
end

-- function to get the position of morpheus font
function CTT:UpdateUsedMedia(event, mediatype, key)
    fontTableOptions = LSM:List("font")
    for k, v in pairs(fontTableOptions) do
        if v == "Morpheus" then
            fontDropDownMorpheus = k
            break
        end
    end

    soundTableOptions = LSM:List("sound")
end

-- Slash Command function
function CTT:SlashCommands(input)
    input = string.lower(input)
    local command, value, _ = strsplit(" ", input)
    if command == "" then
        CTT_ToggleMenu()
    elseif command == "help" then
        CTT:Print(L["======== Combat Time Tracker ========"])
        CTT:Print(L["/ctt - to open the options menu!"])
        CTT:Print(L["/ctt show - to show the tracker if hidden!"])
        CTT:Print(L["/ctt hide - to hide the tracker if shown!"])
        CTT:Print(L["/ctt reset - reset the time on the tracker(done automatically)!"])
        CTT:Print(L["/ctt longest - print longest fight!"])
        CTT:Print(L["/ctt lock -  to lock or unlock the window!"])
        CTT:Print(L["/ctt resetfull - restore addon to default settings."])
        CTT:Print("=================================")
    elseif command == "reset" then
        db.profile.cttMenuOptions.timeValues = { "00", "00", "00", "00" }
        activeProfile = nil
        activeProfileKey = nil
        CTT_UpdateText(db.profile.cttMenuOptions.timeValues[1], db.profile.cttMenuOptions.timeValues[2],
            db.profile.cttMenuOptions.timeValues[3], db.profile.cttMenuOptions.timeValues[5],
            db.profile.cttMenuOptions.dropdownValue, 1)
        CTT:Print(L["Stopwatch has been reset!"])
    elseif command == "show" then
        cttStopwatchGui:Show()
        CTT:Print(L["Stopwatch is now being shown!"])
    elseif command == "hide" then
        cttStopwatchGui:Hide()
        CTT:Print(L["Stopwatch is now being hidden!"])
    elseif command == "resetfull" then
        longestMin = 0
        longestSec = 0
        db.profile.cttMenuOptions.alerts = {}
        db:ResetDB(Default)
        activeProfile = nil
        activeProfileKey = nil
        CTT:Print(L["Combat Time Tracker has been reset to default settings!"])
    elseif command == "longest" then
        CTT:Print(L["Your longest fight took (MM:SS): "]..longestMin..":"..longestSec..L["."])
    elseif command == "lock" then
        if db.profile.cttMenuOptions.lockFrameCheckButton then
            db.profile.cttMenuOptions.lockFrameCheckButton = false
            cttStopwatchGui:EnableMouse(true)
            CTT:Print(L["Tracker has been unlocked!"])
        else
            db.profile.cttMenuOptions.lockFrameCheckButton = true
            cttStopwatchGui:EnableMouse(false)
            CTT:Print(L["Tracker has been locked!"])
        end
        --[==[@debug@
    elseif command == "debug" then
        CallSimulateBossKill()
    elseif command == "resetbosskills" then
        db.profile.RaidKills = nil
        --@end-debug@]==]
    end

end

--|--------------------------|
--| Non AceAddon functions --|
--|--------------------------|

-- function to check if a ui reset is needed.
function CTT_CheckForReload()
    if db.profile.cttMenuOptions.lastVersion == nil then
        db.profile.cttMenuOptions.uiReset = true
        db.profile.cttMenuOptions.lastVersion = C_AddOns.GetAddOnMetadata("CombatTimeTracker", "Version")
    else
        db.profile.cttMenuOptions.uiReset = false
    end
end

function CTT_TableContainsValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function IsInt(n)
    return (type(tonumber(n)) == "number" and (math.floor((tonumber(n))) == tonumber(n)))
end

-- Function To check for players current target
function CTT_CheckForTarget()
    if not db.profile.cttMenuOptions.toggleTarget then return end
    local target = GetUnitName("Target", false)
    local raidMarkerIcon = target ~= nil and GetRaidTargetIndex("Target") or nil
    if target ~= nil then
        cttStopwatchGuiTargetText:SetText(target)
        cttStopwatchGuiTargetText:Show()
        if raidMarkerIcon ~= nil then
            cttStopwatchGuiTargetIcon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. raidMarkerIcon, true)
            cttStopwatchGuiTargetIcon:Show()
            cttStopwatchGuiTargetIcon2:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. raidMarkerIcon,
                true)
            cttStopwatchGuiTargetIcon2:Show()
        else
            cttStopwatchGuiTargetIcon:Hide()
            cttStopwatchGuiTargetIcon2:Hide()
        end
    else
        cttStopwatchGuiTargetText:Hide()
        if cttStopwatchGuiTargetIcon:IsShown() then
            cttStopwatchGuiTargetIcon:Hide()
            cttStopwatchGuiTargetIcon2:Hide()
        end
    end
end

function CTT_CheckToPlaySound()
    if not bossEncounter then return end
    for k, v in pairs(db.profile.cttMenuOptions.alerts) do
        if k ~= "scrollvalue" and k ~= "offset" and
            raidEncounterIDs[db.profile.cttMenuOptions.alerts[k][4]] == bossEncounterName and
            tonumber(totalSeconds) == db.profile.cttMenuOptions.alerts[k][1] then
            lastBossSoundPlayed = totalSeconds
            PlaySoundFile(LSM:Fetch("sound", soundTableOptions[db.profile.cttMenuOptions.soundDropDownValue]), "Master")
        end
    end
end

-- function to handle showing the tracker based on instance type settings
function CTT_InstanceTypeDisplay(key)
    local zone = GetRealZoneText()
    local subZone = GetSubZoneText()

    if key == 1 then
        --Handle dungeons
        for k, v in pairs(instanceZones) do
            if zone == v then
                if not cttStopwatchGui:IsShown() then
                    cttStopwatchGui:Show()
                end
                break
            else
                cttStopwatchGui:Hide()
            end
        end
    elseif key == 2 then
        -- handle raid stuff
        for key, value in ipairs(raidInstanceZones) do
            for k, v in ipairs(value) do
                if zone == v then
                    if not cttStopwatchGui:IsShown() then
                        cttStopwatchGui:Show()
                    end
                    break
                else
                    cttStopwatchGui:Hide()
                end 
            end
        end
    elseif key == 3 then
        -- handle both dungeon and raid stuff

        --Handle dungeons
        for k, v in pairs(instanceZones) do
            if zone == v then
                if not cttStopwatchGui:IsShown() then
                    cttStopwatchGui:Show()
                end
                return
            else
                cttStopwatchGui:Hide()
            end
        end
        -- handle raid stuff
        for key, value in ipairs(raidInstanceZones) do
            for k, v in ipairs(value) do
                if zone == v then
                    if not cttStopwatchGui:IsShown() then
                        cttStopwatchGui:Show()
                    end
                    break
                else
                    cttStopwatchGui:Hide()
                end 
            end
        end
    elseif key == 5 then
        if not (UnitAffectingCombat("player") or bossEncounter) and cttStopwatchGui:IsShown() then cttStopwatchGui:Hide() end
    else
        -- always show
        if not cttStopwatchGui:IsShown() then
            cttStopwatchGui:Show()
        end
        return
    end
end

-- display a popup message
function CTT_PopUpMessage()
    StaticPopupDialogs["NEW_VERSION"] = {
        text = L["Combat Time Tracker has been updated, the tracker needs to be reset to work properly!"],
        button1 = L["Reset Now"],
        button2 = L["Reset Later"],
        OnAccept = function()
            db.profile.cttMenuOptions.uiReset = false
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("NEW_VERSION")
end

-- function to display results on ecounter end or regen enabled
function CTT_DisplayResults(newRecord)
    if not db.profile.cttMenuOptions.togglePrint then return end
    if db.profile.cttMenuOptions.dropdownValue == 1 then
        if newRecord then
            CTT:Print(L["New Record! Fight ended in "] ..
                db.profile.cttMenuOptions.timeValues[4] ..
                "." .. db.profile.cttMenuOptions.timeValues[5] .. " " .. L["seconds"] .. "!")
        else
            CTT:Print(L["Fight ended in "] ..
                db.profile.cttMenuOptions.timeValues[4] ..
                "." .. db.profile.cttMenuOptions.timeValues[5] .. " " .. L["seconds"] .. L["."])
        end
    elseif db.profile.cttMenuOptions.dropdownValue == 2 then
        if newRecord then
            CTT:Print(L["New Record! Fight ended in "] ..
                "(MM:SS.MS): " ..
                db.profile.cttMenuOptions.timeValues[2] ..
                ":" .. db.profile.cttMenuOptions.timeValues[3] .. "." .. db.profile.cttMenuOptions.timeValues[5] .. "!")
        else
            CTT:Print(L["Fight ended in "] ..
                "(MM:SS.MS): " ..
                db.profile.cttMenuOptions.timeValues[2] ..
                ":" .. db.profile.cttMenuOptions.timeValues[3] .. "." .. db.profile.cttMenuOptions.timeValues[5] .. L["."])
        end
    else
        if newRecord then
            CTT:Print(L["New Record! Fight ended in "] ..
                "(HH:MM:SS.MS): " ..
                db.profile.cttMenuOptions.timeValues[1] ..
                ":" ..
                db.profile.cttMenuOptions.timeValues[2] ..
                ":" .. db.profile.cttMenuOptions.timeValues[3] .. "." .. db.profile.cttMenuOptions.timeValues[5] .. "!")
        else
            CTT:Print(L["Fight ended in "] ..
                "(HH:MM:SS.MS): " ..
                db.profile.cttMenuOptions.timeValues[1] ..
                ":" ..
                db.profile.cttMenuOptions.timeValues[2] ..
                ":" .. db.profile.cttMenuOptions.timeValues[3] .. "." .. db.profile.cttMenuOptions.timeValues[5] .. L["."])
        end
    end
end

-- Get expansion by encounter identity
function CTT_GetExpansionByEncounterId(encounterId)
    for index, value in ipairs(raidEncounterIDs) do
        for i, v in ipairs(value) do
            for index2, value2 in ipairs(v) do
                if value2 == encounterId then
                    return xpacs[index]
                end
            end
        end
    end

    return nil
end

-- Get raid instance
function CTT_GetRaidByZoneText()
    local zone = GetRealZoneText()
    -- handle raid stuff
    for key, value in ipairs(raidInstanceZones) do
        for k, v in ipairs(value) do
            if zone == v then
                return v
            end
        end
    end
    return nil
end

-- Get Bossname
function CTT_GetDifficultyById(id)
    local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID, isLFR, minPlayers, maxPlayers = GetDifficultyInfo(id)
    return name
end

-- Store boss kills after a kill
function CTT_StoreBossKills(expansion, raidInstance, bossName, groupSize, difficulty, success)
    if expansion == nil or raidInstance == nil or bossName == nil or groupSize == nil or difficulty == nil or success == nil then return end
    local data = {
        Expansion = expansion,
        RaidInstance = raidInstance,
        BossName = bossName,
        KillTime = cttStopwatchGuiTimeText:GetText(),
        Success = success,
        Difficulty = difficulty,
        GroupSize = groupSize,
        LocalKillTime = date("%m/%d/%Y %I:%M%p")
    }

    local key = 0

    if db.profile.RaidKills ~= nil then
        key = table.getn(db.profile.RaidKills) + 1
        db.profile.RaidKills[key] = data
    else
        db.profile.RaidKills = {}
        db.profile.RaidKills[key] = data
    end
end

-- function to fix display results on a boss encounter ending
function CTT_DisplayResultsBosses(bossEncounter, wasAKill)
    if not db.profile.cttMenuOptions.togglePrint then return end
    if db.profile.cttMenuOptions.dropdownValue == 1 then
        if wasAKill then
            CTT:Print(L["You have successfully killed "] ..
                bossEncounter ..
                " " .. L["after"] .. " " .. totalSeconds .. "." .. miliseconds .. " " .. L["seconds"] .. "!")
        else
            CTT:Print(L["You have wiped on "] ..
                bossEncounter .. L["after"] .. " " .. totalSeconds .. "." .. miliseconds .. L["."])
        end
    elseif db.profile.cttMenuOptions.dropdownValue == 2 then
        if wasAKill then
            CTT:Print(L["You have successfully killed "] ..
                bossEncounter .. " " .. L["after"] .. " " .. minutes .. ":" .. seconds .. "." .. miliseconds .. "!")
        else
            CTT:Print(L["You have wiped on "] ..
                bossEncounter .. " " .. L["after"] .. " " .. minutes .. ":" .. seconds .. "." .. miliseconds .. L["."])
        end
    else
        if wasAKill then
            CTT:Print(L["You have successfully killed "] ..
                bossEncounter ..
                " " .. L["after"] .. " " .. hours .. ":" .. minutes .. ":" .. seconds .. "." .. miliseconds .. L["."])
        else
            CTT:Print(L["You have wiped on "] ..
                bossEncounter ..
                " " .. L["after"] .. " " .. hours .. ":" .. minutes .. ":" .. seconds .. "." .. miliseconds .. L["."])
        end
    end
end

-- function to update the text on the tracker frame
function CTT_UpdateText(hours, minutes, seconds, miliseconds, textFormat, fontUpdate)
    if fontUpdate == 2 then
        cttStopwatchGuiTimeText:SetText("")
    end
    if textFormat == 1 then
        if db.profile.cttMenuOptions.timeValues then
            cttStopwatchGuiTimeText:SetText(totalSeconds) -- .. "." .. miliseconds)
        else
            cttStopwatchGuiTimeText:SetText(seconds) -- .. "." .. miliseconds)
        end
    elseif textFormat == 2 then
        cttStopwatchGuiTimeText:SetText(minutes .. ":" .. seconds) -- .. "." .. miliseconds)
    elseif textFormat == 4 then
        cttStopwatchGuiTimeText:SetText(minutes .. ":" .. seconds .. "." .. miliseconds)
    elseif textFormat == 5 then
        cttStopwatchGuiTimeText:SetText(minutes .. ":" .. seconds .. ":" .. miliseconds)
    else
        cttStopwatchGuiTimeText:SetText(hours .. ":" .. minutes .. ":" .. seconds) -- .. "." .. miliseconds)
    end
end

function CTT_UpdateMenuTexts(container, difficultyNumber)
    if difficultyNumber == 1 then
        difficultyNumber = 0
    elseif difficultyNumber == 2 then
        difficultyNumber = 9
    elseif difficultyNumber == 3 then
        difficultyNumber = 18
    else
        difficultyNumber = 27
    end
end

function CTT_CoSUpdateMenuTexts(container, difficultyNumber)
    if difficultyNumber == 1 then
        difficultyNumber = 0
    elseif difficultyNumber == 2 then
        difficultyNumber = 2
    elseif difficultyNumber == 3 then
        difficultyNumber = 4
    else
        difficultyNumber = 6
    end

    container.CabalTime:SetText(cosFightLogs[1 + difficultyNumber])
    container.UunatTime:SetText(cosFightLogs[2 + difficultyNumber])
end

function CTT_tepUpdateMenuTexts(container, difficultyNumber)
    if difficultyNumber == 1 then
        difficultyNumber = 0
    elseif difficultyNumber == 2 then
        difficultyNumber = 8
    elseif difficultyNumber == 3 then
        difficultyNumber = 16
    else
        difficultyNumber = 24
    end

    container.ACSTime:SetText(tepFightLogs[1 + difficultyNumber])
    container.BBTime:SetText(tepFightLogs[2 + difficultyNumber])
    container.RoATime:SetText(tepFightLogs[3 + difficultyNumber])
    container.LATime:SetText(tepFightLogs[4 + difficultyNumber])
    container.OTime:SetText(tepFightLogs[5 + difficultyNumber])
    container.TQCTime:SetText(tepFightLogs[6 + difficultyNumber])
    container.ZHoNTime:SetText(tepFightLogs[7 + difficultyNumber])
    container.QATime:SetText(tepFightLogs[8 + difficultyNumber])
end

--|-----------------------|
--| AceGUI Options Menu --|
--|-----------------------|

-- function to toggle the options menu
function CTT_ToggleMenu()
    if UnitAffectingCombat("player") or bossEncounter then
        loadOptionsAfterCombat = true
        CTT:Print(L["Options menu cannot be loaded while in combat, try again after combat has ended!"])
    else
        if CTT.menu == nil then
            CTT:CreateOptionsMenu()
        end
        if CTT.menu:IsShown() then
            CTT.menu:Hide()
            -- CTT:Print(L["Options menu hidden, for other commands use /ctt help!"]) - 隱藏登入訊息
        else
            CTT.menu:Show()
            -- CTT:Print(L["Options menu loaded, for other commands use /ctt help!"]) - 隱藏登入訊息
        end
    end
end

function CTT_LockFrameCheckBoxState(widget, event, value)
    db.profile.cttMenuOptions.lockFrameCheckButton = value
    if db.profile.cttMenuOptions.lockFrameCheckButton then
        cttStopwatchGui:EnableMouse(false)
        CTT:Print(L["Tracker has been locked!"])
    else
        cttStopwatchGui:EnableMouse(true)
        CTT:Print(L["Tracker has been unlocked!"])
    end
end

function CTT_ColorPickerConfirmed(widget, event, r, g, b, a)
    db.profile.cttMenuOptions.textColorPicker = { r, g, b, a }
    cttStopwatchGuiTimeText:SetTextColor(r, g, b, a)
end

function CTT_DropdownState(widget, event, key, checked)
    db.profile.cttMenuOptions.dropdownValue = key
    CTT_UpdateText(db.profile.cttMenuOptions.timeValues[1], db.profile.cttMenuOptions.timeValues[2],
        db.profile.cttMenuOptions.timeValues[3], db.profile.cttMenuOptions.timeValues[5],
        db.profile.cttMenuOptions.dropdownValue, 1)
end

-- function to handle the sliding of the slider, this fires anytime the slider moves
function CTT_ResizeFrameSliderUpdater(widget, event, value)
    db.profile.cttMenuOptions.textFrameSizeSlider = value
    local multiplier = value
    local width = 100 + (multiplier * 100)
    local height = 40 + (multiplier * 40)
    local targetSizeHeight = 12.5 + (multiplier * 12.5)
    local targetSizeWidth = 50 + (multiplier * 50)
    local fontVal = 16 + (multiplier * 16)
    local iconSize = 7.5 + (multiplier * 7.5)
    cttStopwatchGui:SetWidth(width)
    cttStopwatchGui:SetHeight(height)
    cttStopwatchGuiTimeText:SetSize(width, height)
    if db.profile.cttMenuOptions.toggleTarget then
        cttStopwatchGuiTargetText:SetSize(targetSizeWidth, targetSizeHeight)
        cttStopwatchGuiTargetIcon:SetSize(iconSize, iconSize)
        cttStopwatchGuiTargetIcon2:SetSize(iconSize, iconSize)
    end
    -- TODO add target text to ctt db for persistence
    -- TODO add dynamic absolute offset for target raid icons
    if db.profile.cttMenuOptions.fontName then
        cttStopwatchGuiTimeText:SetFont(db.profile.cttMenuOptions.fontName, fontVal, db.profile.cttMenuOptions.fontFlags)
        if db.profile.cttMenuOptions.toggleTarget then
            cttStopwatchGuiTargetText:SetFont(db.profile.cttMenuOptions.fontName
            , fontVal / 2, db.profile.cttMenuOptions.fontFlags)
        end
        db.profile.cttMenuOptions.fontVal = fontVal
    else
        cttStopwatchGuiTimeText:SetFont(STANDARD_TEXT_FONT, fontVal, db.profile.cttMenuOptions.fontFlags)
        if db.profile.cttMenuOptions.toggleTarget then
            cttStopwatchGuiTargetText:SetFont(STANDARD_TEXT_FONT,
                fontVal /
                2, db.profile.cttMenuOptions.fontFlags)
        end
        db.profile.cttMenuOptions.fontVal = fontVal
    end
end

-- function to update the tracker size from user settings on login
function CTT_SetTrackerSizeOnLogin()
    if table.getn(db.profile.cttMenuOptions.timeTrackerSize) == 2 and db.profile.cttMenuOptions.fontVal and
        db.profile.cttMenuOptions.fontName and db.profile.cttMenuOptions.backDropAlphaSlider then
        cttStopwatchGui:SetWidth(db.profile.cttMenuOptions.timeTrackerSize[1])
        cttStopwatchGui:SetHeight(db.profile.cttMenuOptions.timeTrackerSize[2])
        cttStopwatchGuiTimeText:SetSize(db.profile.cttMenuOptions.timeTrackerSize[1],
            db.profile.cttMenuOptions.timeTrackerSize[2])
        cttStopwatchGuiTimeText:SetFont(db.profile.cttMenuOptions.fontName, db.profile.cttMenuOptions.fontVal,
            db.profile.cttMenuOptions.fontFlags)
        cttStopwatchGui:SetBackdrop(backdropSettings)
        cttStopwatchGui:SetBackdropColor(0, 0, 0, db.profile.cttMenuOptions.backDropAlphaSlider)
        cttStopwatchGui:SetBackdropBorderColor(255, 255, 255, db.profile.cttMenuOptions.backDropAlphaSlider)
        cttStopwatchGuiTimeText:SetTextColor(db.profile.cttMenuOptions.textColorPicker[1],
            db.profile.cttMenuOptions.textColorPicker[2], db.profile.cttMenuOptions.textColorPicker[3],
            db.profile.cttMenuOptions.textColorPicker[4])
        cttStopwatchGui:ClearAllPoints()
        cttStopwatchGui:SetPoint(db.profile.cttMenuOptions.framePoint, nil, db.profile.cttMenuOptions.frameRelativePoint
            , db.profile.cttMenuOptions.xOfs, db.profile.cttMenuOptions.yOfs)
    else
        cttStopwatchGuiTimeText:SetFont(STANDARD_TEXT_FONT, 16, db.profile.cttMenuOptions.fontFlags)
        db.profile.cttMenuOptions.fontVal = fontVal
    end
end

-- SetCallBack function that handles when the person stops sliding the slider
function CTT_ResizeFrameSliderDone(widget, event, value)
    db.profile.cttMenuOptions.textFrameSizeSlider = value
    db.profile.cttMenuOptions.timeTrackerSize = { cttStopwatchGui:GetWidth(), cttStopwatchGui:GetHeight() }
end

-- Callback function for the font picker dropdown
function CTT_FontPickerDropDownState(widget, event, key, checked)
    db.profile.cttMenuOptions.fontPickerDropDown = key
    db.profile.cttMenuOptions.fontName = LSM:Fetch("font", fontTableOptions[key])
    if table.getn(db.profile.cttMenuOptions.timeTrackerSize) == 2 and db.profile.cttMenuOptions.fontVal and
        db.profile.cttMenuOptions.fontName then
        cttStopwatchGui:SetWidth(db.profile.cttMenuOptions.timeTrackerSize[1])
        cttStopwatchGui:SetHeight(db.profile.cttMenuOptions.timeTrackerSize[2])
        cttStopwatchGuiTimeText:SetSize(db.profile.cttMenuOptions.timeTrackerSize[1],
            db.profile.cttMenuOptions.timeTrackerSize[2])
        cttStopwatchGuiTimeText:SetFont(db.profile.cttMenuOptions.fontName, db.profile.cttMenuOptions.fontVal,
            db.profile.cttMenuOptions.fontFlags)
        CTT_UpdateText(db.profile.cttMenuOptions.timeValues[1], db.profile.cttMenuOptions.timeValues[2],
            db.profile.cttMenuOptions.timeValues[3], db.profile.cttMenuOptions.timeValues[5],
            db.profile.cttMenuOptions.dropdownValue, 2)
    end
end

-- callback for the backdrop opacity slider while moving
function CTT_BackDropSliderOnValueChanged(widget, event, value)
    db.profile.cttMenuOptions.backDropAlphaSlider = value
    cttStopwatchGui:SetBackdropColor(0, 0, 0, value)
    cttStopwatchGui:SetBackdropBorderColor(255, 255, 255, value)
end

-- callback for the backdrop opacity slider when dont moving
function CTT_BackDropSliderDone(widget, event, value)
    db.profile.cttMenuOptions.backDropAlphaSlider = value
end

function CTT_MinimapIconCheckButton(widget, event, value)
    if (db.minimap == nil) then
        db.minimap = {
            hide = value,
        }
    end
    db.profile.cttMenuOptions.minimapIconCheckButton = value
    if db.profile.cttMenuOptions.minimapIconCheckButton then
        icon:Hide("CombatTimeTracker")
    else
        icon:Show("CombatTimeTracker")
    end
end

function CTT_ToggleTargetCheckButton(widget, event, value)
    db.profile.cttMenuOptions.toggleTarget = value
    if db.profile.cttMenuOptions.toggleTarget then
        cttStopwatchGuiTargetText:Show()
    else
        cttStopwatchGuiTargetText:Hide()
    end
end

function CTT_ToggleClickThroughCheckButton(widget, event, value)
    db.profile.cttMenuOptions.clickThrough = value
    if db.profile.cttMenuOptions.clickThrough then
        cttStopwatchGui:EnableMouse(value)
    else
        cttStopwatchGui:EnableMouse(value)
    end
end

function CTT_TogglePrintCheckButton(widget, event, value)
    db.profile.cttMenuOptions.togglePrint = value;
end

function CTT_ToggleTextFlagsButton(widget, event, value)
    db.profile.cttMenuOptions.textFlags = value
    if value then
        db.profile.cttMenuOptions.fontFlags = "OUTLINE, THICKOUTLINE, MONOCHROME"
    else
        db.profile.cttMenuOptions
        .fontFlags = ""
    end
    CTT_SetTrackerSizeOnLogin()
end

function CTT_InstanceTypeDropDown(widget, event, key, checked)
    local zone = GetRealZoneText()
    db.profile.cttMenuOptions.instanceType = key
    if key ~= 4 then
        CTT_InstanceTypeDisplay(key)
    elseif key == 5 then
        if cttStopwatchGui:IsShown() then
            return
        else
            cttStopwatchGui:Hide()
        end
    else
        if cttStopwatchGui:IsShown() then
            return
        else
            cttStopwatchGui:Show()
        end
    end
end

function CTT_DifficultyDropDown(widget, event, key, checked)
    db.profile.cttMenuOptions.difficultyDropDown = key
    if key == 1 then
        -- TODO LFR times
        CTT_UpdateMenuTexts(menu.tab, key)
    elseif key == 2 then
        -- TODO normal times
        CTT_UpdateMenuTexts(menu.tab, key)
    elseif key == 3 then
        -- TODO heroic times
        CTT_UpdateMenuTexts(menu.tab, key)
    else
        -- TODO mythic times
        CTT_UpdateMenuTexts(menu.tab, key)
    end
end

function CTT_cosDifficultyDropDown(widget, event, key, checked)
    db.profile.cttMenuOptions.difficultyDropDown2 = key
    if key == 1 then
        -- TODO LFR times
        CTT_CoSUpdateMenuTexts(menu.tab, key)
    elseif key == 2 then
        -- TODO normal times
        CTT_CoSUpdateMenuTexts(menu.tab, key)
    elseif key == 3 then
        -- TODO heroic times
        CTT_CoSUpdateMenuTexts(menu.tab, key)
    else
        -- TODO mythic times
        CTT_CoSUpdateMenuTexts(menu.tab, key)
    end
end

function CTT_tepDifficultyDropDown(widget, event, key, checked)
    db.profile.cttMenuOptions.difficultyDropDown3 = key
    if key == 1 then
        -- TODO LFR times
        CTT_tepUpdateMenuTexts(menu.tab, key)
    elseif key == 2 then
        -- TODO normal times
        CTT_tepUpdateMenuTexts(menu.tab, key)
    elseif key == 3 then
        -- TODO heroic times
        CTT_tepUpdateMenuTexts(menu.tab, key)
    else
        -- TODO mythic times
        CTT_tepUpdateMenuTexts(menu.tab, key)
    end
end

function CTT_PlaySoundOnDropDownSelect(widget, event, key, checked)
    db.profile.cttMenuOptions.soundDropDownValue = key
    db.profile.cttMenuOptions.soundName = LSM:Fetch("sound", soundTableOptions[key])
    PlaySoundFile(LSM:Fetch("sound", soundTableOptions[key]), "Master")
end

function CTT_AlertTimeOnEnterPressed(widget, event, text)
    db.profile.cttMenuOptions.localStore = text
end

function CTT_AlertRaidDropDown(widget, event, key, checked)
    db.profile.cttMenuOptions.raidKey = key
    db.profile.cttMenuOptions.raidDropdown = raidInstanceZones[db.profile.cttMenuOptions.xpacKey][key]
    CTT.menu.tab:SelectTab("alerts")
end

function CTT_AlertRaidDropDownForRaidTab(widget, event, key, checked)
    db.profile.cttMenuOptions.raidKey = key
    db.profile.cttMenuOptions.raidDropdown = raidInstanceZones[db.profile.cttMenuOptions.xpacKey][key]
    CTT.menu.tab:SelectTab("raids")
end

function CTT_ExpansionDropDown(widget, event, key, checked)
    db.profile.cttMenuOptions.xpacKey = key
    CTT.menu.tab:SelectTab("alerts")
end

function CTT_ExpansionDropDownForRaidTab(widget, event, key, checked)
    db.profile.cttMenuOptions.xpacKey = key
    CTT.menu.tab:SelectTab("raids")
end

function CTT_AlertBossDropDown(widget, event, key, checked)
    db.profile.cttMenuOptions.bossDropdown = raidBosses[db.profile.cttMenuOptions.xpacKey][
        db.profile.cttMenuOptions.raidKey][key]
    db.profile.cttMenuOptions.bossDropDownkey = key
    CTT.menu.tab:SelectTab("alerts")
end

function CTT_AlertBossDropDownForRaidTab(widget, event, key, checked)
    db.profile.cttMenuOptions.bossDropdown = raidBosses[db.profile.cttMenuOptions.xpacKey][
    db.profile.cttMenuOptions.raidKey][key]
    db.profile.cttMenuOptions.bossDropDownkey = key
    CTT.menu.tab:SelectTab("raids")
end

function CTT_ClearAlertBossRaidTab()
    if db.profile.RaidKills ~= nil then
        db.profile.RaidKills = {}
    end
    CTT.menu.tab:SelectTab("raids")
end

function CTT_AlertAddButtonClicked(widget, event)
    local timeInSeconds = IsInt(db.profile.cttMenuOptions.localStore)
    local key = 0
    if db.profile.cttMenuOptions.alerts[table.getn(db.profile.cttMenuOptions.alerts)] ~= {} then key = 1 end
    if db.profile.cttMenuOptions.localStore ~= nil and timeInSeconds and db.profile.cttMenuOptions.raidDropdown ~= nil
        and db.profile.cttMenuOptions.bossDropdown ~= nil then
        db.profile.cttMenuOptions.alerts[table.getn(db.profile.cttMenuOptions.alerts) + key] = {
            tonumber(db.profile.cttMenuOptions
                .localStore), raidInstanceZones[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey],
            raidBosses[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey][
                db.profile.cttMenuOptions.bossDropDownkey],
            raidEncounterIDs[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey][
                db.profile.cttMenuOptions.bossDropDownkey] }
        CTT.menu.tab:SelectTab("alerts")
    else
        if not timeInSeconds then
            CTT_AlertsErrorPopup(1)
        elseif db.profile.cttMenuOptions.raidDropdown == nil then
            CTT_AlertsErrorPopup(2)
        elseif db.profile.cttMenuOptions.bossDropdown == nil then
            CTT_AlertsErrorPopup(3)
        end
    end
end

function CTT_AlertDeleteButtonClicked(widget, event, key)
    table.remove(db.profile.cttMenuOptions.alerts, key)
    CTT.menu.tab:SelectTab("alerts")
end

function CTT_AlertDeleteButtonClickedForRaidTab(widget, event, key)
    table.remove(db.profile.RaidKills, key)
    CTT.menu.tab:SelectTab("raids")
end

function CTT_AlertsErrorPopup(errorCode)
    local text = L["You must enter values!"]

    if errorCode == 1 then
        text = L["You must enter a valid time in seconds (no decimal vaues!!! e.g. 100 not 100.1)!"]
    elseif errorCode == 2 then
        text = L["You must select a raid!"]
    elseif errorCode == 3 then
        text = L["You must select a boss!"]
    end

    StaticPopupDialogs["AlertError"] = {
        text = text,
        button1 = OKAY,
        -- button2 = "Reset Later",
        OnAccept = function()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("AlertError")
end

function CTT_ProfileNameOnEnterPressed(widget, event, text)
    local textToUse = string.gsub(text, "^%s*(.-)%s*$", "%1")
    if textToUse ~= nil and textToUse ~= "" then
        newProfileName = text
    else
        StaticPopupDialogs["ProfileNameError"] = {
            text = L["You have entered and invalid profile name, please try again!"],
            button1 = OKAY,
            -- button2 = "Reset Later",
            OnAccept = function()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("ProfileNameError")
    end
end

function CTT_ProfileDropDownPicker(widget, event, key)
    activeProfileKey = key
    activeProfile = db:GetProfiles()[key]
    db:SetProfile(db:GetProfiles()[key])
    CTT.menu.tab:SelectTab("options")
    CTT:Print(activeProfile .. L[" profile is now the active profile!"])
    CTT_SetTrackerSizeOnLogin()
end

function CTT_ProfileAddButton(widget, event)
    activeProfile = newProfileName
    db:SetProfile(newProfileName)
    CTT:Print(L["New profile with the name of "] .. newProfileName .. L[" has been created!"])
    CTT.menu.tab:SelectTab("options")
end

function CTT_ProfileCopyDropdown(widget, event, key)
    CTT:Print(activeProfile .. L[" has been updated to a copy of "] .. db:GetProfiles()[key] .. "!")
    db:CopyProfile(db:GetProfiles()[key], true)
    CTT.menu.tab:SelectTab("options")
end

function CTT_ProfileDeleteDropdown(widget, event, key)
    CTT:Print(db:GetProfiles()[key] .. L[" profile has been deleted!"])
    db:DeleteProfile(db:GetProfiles()[key], true)
    CTT.menu.tab:SelectTab("options")
end

function CTT_ResetTrackerOnCombatEnding(widget, event, value)
    --[==[@debug@
    CTT:Print(db.profile.cttMenuOptions.resetCounterOnEndOfCombat)
    CTT:Print(value)
    --@end-debug@]==]
    if not value then
        time = GetTime()
        cttElapsedSeconds = 0
    end
    db.profile.cttMenuOptions.resetCounterOnEndOfCombat = value;
end

--|-----------------------|
--| AceGUI Raid Bosses  --|
--|-----------------------|


--function that draws the widgets for the first tab
local function OptionsMenu(container)
    -- frame lock button
    local lockFrameCheckButton = AceGUI:Create("CheckBox")
    lockFrameCheckButton:SetLabel(L["Lock"])
    lockFrameCheckButton:SetWidth(100)
    lockFrameCheckButton:SetHeight(22)
    lockFrameCheckButton:SetType("checkbox")
    lockFrameCheckButton:ClearAllPoints()
    if db.profile.cttMenuOptions.lockFrameCheckButton ~= nil then lockFrameCheckButton:SetValue(db.profile.cttMenuOptions.lockFrameCheckButton) end
    lockFrameCheckButton:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    lockFrameCheckButton:SetCallback("OnValueChanged", CTT_LockFrameCheckBoxState)
    container:AddChild(lockFrameCheckButton)
    container.lockFrameCheckButton = lockFrameCheckButton

    -- minimap icon check button
    local minimapIconCheckButton = AceGUI:Create("CheckBox")
    minimapIconCheckButton:SetLabel(L["Hide Minimap"])
    minimapIconCheckButton:SetWidth(150)
    minimapIconCheckButton:SetHeight(22)
    minimapIconCheckButton:SetType("checkbox")
    minimapIconCheckButton:ClearAllPoints()
    if db.profile.cttMenuOptions.minimapIconCheckButton ~= nil then
        minimapIconCheckButton:SetValue(db.profile.cttMenuOptions.minimapIconCheckButton)
    else
        minimapIconCheckButton:SetValue(false)
    end
    minimapIconCheckButton:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    --minimapIconCheckButton:SetCallBack("OnValueChanged", CTT_MinimapIconCheckButton)
    minimapIconCheckButton:SetCallback("OnValueChanged", CTT_MinimapIconCheckButton)
    container:AddChild(minimapIconCheckButton)
    container.minimapIconCheckButton = minimapIconCheckButton

    -- toggle target checkbox
    local toggleTarget = AceGUI:Create("CheckBox")
    toggleTarget:SetLabel(L["Show Target"])
    toggleTarget:SetWidth(115)
    toggleTarget:SetHeight(22)
    toggleTarget:SetType("checkbox")
    toggleTarget:ClearAllPoints()
    if db.profile.cttMenuOptions.toggleTarget ~= nil then
        toggleTarget:SetValue(db.profile.cttMenuOptions.toggleTarget)
    else
        toggleTarget:SetValue(true)
    end
    toggleTarget:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    toggleTarget:SetCallback("OnValueChanged", CTT_ToggleTargetCheckButton)
    container:AddChild(toggleTarget)
    container.toggleTarget = toggleTarget

    -- toggle printing
    local togglePrint = AceGUI:Create("CheckBox")
    togglePrint:SetLabel(L["Toggle Messages"])
    togglePrint:SetWidth(150)
    togglePrint:SetHeight(22)
    togglePrint:SetType("checkbox")
    togglePrint:ClearAllPoints()
    if db.profile.cttMenuOptions.togglePrint ~= nil then
        togglePrint:SetValue(db.profile.cttMenuOptions.togglePrint)
    else
        togglePrint:SetValue(true)
    end
    togglePrint:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    togglePrint:SetCallback("OnValueChanged", CTT_TogglePrintCheckButton)
    container:AddChild(togglePrint)
    container.togglePrint = togglePrint

    -- color picker
    local textColorPicker = AceGUI:Create("ColorPicker")
    if db.profile.cttMenuOptions.textColorPicker ~= nil then
        textColorPicker:SetColor(db.profile.cttMenuOptions.textColorPicker[1],
            db.profile.cttMenuOptions.textColorPicker[2], db.profile.cttMenuOptions.textColorPicker[3],
            db.profile.cttMenuOptions.textColorPicker[4])
    else
        textColorPicker:SetColor(255, 255, 255)
    end
    textColorPicker:SetLabel(L["Text Color"])
    textColorPicker:SetWidth(100)
    textColorPicker:ClearAllPoints()
    textColorPicker:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    textColorPicker:SetCallback("OnValueChanged", CTT_ColorPickerConfirmed)
    container:AddChild(textColorPicker)
    container.textColorPicker = textColorPicker

    -- checkbox for text outline
    local textFlagsButton = AceGUI:Create("CheckBox")
    textFlagsButton:SetLabel(L["TextOutline"])
    textFlagsButton:SetWidth(125)
    textFlagsButton:SetHeight(22)
    textFlagsButton:SetType("checkbox")
    textFlagsButton:ClearAllPoints()
    textFlagsButton:SetValue(db.profile.cttMenuOptions.textFlags)
    textFlagsButton:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    textFlagsButton:SetCallback("OnValueChanged", CTT_ToggleTextFlagsButton)
    container:AddChild(textFlagsButton)
    container.textFlagsButton = textFlagsButton

    -- Checkbox for not resetting tracter after combat
    local resetTrackerOnCombatEnding = AceGUI:Create("CheckBox")
    resetTrackerOnCombatEnding:SetLabel(L["Reset After Combat"])
    resetTrackerOnCombatEnding:SetWidth(160)
    resetTrackerOnCombatEnding:SetHeight(22)
    resetTrackerOnCombatEnding:SetType("checkbox")
    resetTrackerOnCombatEnding:ClearAllPoints()
    resetTrackerOnCombatEnding:SetValue(db.profile.cttMenuOptions.resetCounterOnEndOfCombat)
    resetTrackerOnCombatEnding:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    resetTrackerOnCombatEnding:SetCallback("OnValueChanged", CTT_ResetTrackerOnCombatEnding)
    container:AddChild(resetTrackerOnCombatEnding)
    container.resetTrackerOnCombatEnding = resetTrackerOnCombatEnding

    -- different text options
    local textStyleDropDown = AceGUI:Create("Dropdown")
    textStyleDropDown:SetLabel(L["Text Format"])
    textStyleDropDown:SetWidth(125)
    textStyleDropDown:SetMultiselect(false)
    textStyleDropDown:ClearAllPoints()
    textStyleDropDown:SetList(db.profile.cttMenuOptions.cttTextFormatOptions)
    textStyleDropDown:SetText(db.profile.cttMenuOptions.cttTextFormatOptions[db.profile.cttMenuOptions.dropdownValue])
    textStyleDropDown:SetValue(db.profile.cttMenuOptions.dropdownValue)
    textStyleDropDown:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    textStyleDropDown:SetCallback("OnValueChanged", CTT_DropdownState)
    container:AddChild(textStyleDropDown)
    container.textStyleDropDown = textStyleDropDown

    -- slider for changing the size of the tracker and text
    local textFrameSizeSlider = AceGUI:Create("Slider")
    textFrameSizeSlider:SetLabel(L["Tracker Size"])
    textFrameSizeSlider:SetWidth(150)
    textFrameSizeSlider:SetIsPercent(true)
    if db.profile.cttMenuOptions.textFrameSizeSlider ~= nil then
        textFrameSizeSlider:SetValue(db.profile.cttMenuOptions
            .textFrameSizeSlider)
    end
    textFrameSizeSlider:SetSliderValues(0, 1, .01)
    textFrameSizeSlider:ClearAllPoints()
    textFrameSizeSlider:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    textFrameSizeSlider:SetCallback("OnValueChanged", CTT_ResizeFrameSliderUpdater)
    textFrameSizeSlider:SetCallback("OnMouseUp", CTT_ResizeFrameSliderDone)
    container:AddChild(textFrameSizeSlider)
    container.textFrameSizeSlider = textFrameSizeSlider

    -- Slider for the opacity of the backdrop and/or border
    local backDropAlphaSlider = AceGUI:Create("Slider")
    backDropAlphaSlider:SetLabel(L["Backdrop Opacity"])
    backDropAlphaSlider:SetWidth(150)
    backDropAlphaSlider:SetIsPercent(true)
    if db.profile.cttMenuOptions.backDropAlphaSlider ~= nil then
        backDropAlphaSlider:SetValue(db.profile.cttMenuOptions.backDropAlphaSlider)
    else
        backDropAlphaSlider:SetValue(1)
    end
    backDropAlphaSlider:SetSliderValues(0, 1, .01)
    backDropAlphaSlider:ClearAllPoints()
    backDropAlphaSlider:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    backDropAlphaSlider:SetCallback("OnValueChanged", CTT_BackDropSliderOnValueChanged)
    backDropAlphaSlider:SetCallback("OnMouseUp", CTT_BackDropSliderDone)
    container:AddChild(backDropAlphaSlider)
    container.backDropAlphaSlider = backDropAlphaSlider

    -- toggle click through
    local clickThrough = AceGUI:Create("CheckBox")
    clickThrough:SetLabel(L["Click Through"])
    clickThrough:SetWidth(120)
    clickThrough:SetHeight(22)
    clickThrough:SetType("checkbox")
    clickThrough:ClearAllPoints()
    if db.profile.cttMenuOptions.clickThrough ~= nil then
        clickThrough:SetValue(db.profile.cttMenuOptions.clickThrough)
    else
        db.profile.cttMenuOptions.clickThrough = true
        clickThrough:SetValue(true)
    end
    cttStopwatchGui:EnableMouse(db.profile.cttMenuOptions.clickThrough)
    clickThrough:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 0)
    clickThrough:SetCallback("OnValueChanged", CTT_ToggleClickThroughCheckButton)
    container:AddChild(clickThrough)
    container.clickThrough = clickThrough


    -- Dropdown for different font options
    local fontPickerDropDown = AceGUI:Create("Dropdown")
    fontPickerDropDown:SetLabel(L["Choose Font"])
    fontPickerDropDown:SetWidth(270)
    fontPickerDropDown:SetMultiselect(false)
    fontPickerDropDown:ClearAllPoints()
    fontPickerDropDown:SetList(LSM:List("font"))
    if db.profile.cttMenuOptions.fontName ~= nil and db.profile.cttMenuOptions.fontPickerDropDown ~= nil then
        fontPickerDropDown:SetText(fontTableOptions[db.profile.cttMenuOptions.fontPickerDropDown])
        fontPickerDropDown:SetValue(db.profile.cttMenuOptions.fontPickerDropDown)
    else
        fontPickerDropDown:SetText("Morpheus")
        fontPickerDropDown:SetValue(fontDropDownMorpheus)
    end
    fontPickerDropDown:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    fontPickerDropDown:SetCallback("OnValueChanged", CTT_FontPickerDropDownState)
    container:AddChild(fontPickerDropDown)
    container.fontPickerDropDown = fontPickerDropDown

    -- Dropdown for different sound options
    local soundPickerDropDown = AceGUI:Create("Dropdown")
    soundPickerDropDown:SetLabel(L["Choose Sound"])
    soundPickerDropDown:SetWidth(270)
    soundPickerDropDown:SetMultiselect(false)
    soundPickerDropDown:ClearAllPoints()
    soundPickerDropDown:SetList(LSM:List("sound"))
    if db.profile.cttMenuOptions.soundName ~= nil and db.profile.cttMenuOptions.soundDropDownValue ~= nil then
        soundPickerDropDown:SetText(soundTableOptions[db.profile.cttMenuOptions.soundDropDownValue])
        soundPickerDropDown:SetValue(db.profile.cttMenuOptions.soundDropDownValue)
    else
        soundPickerDropDown:SetText("")
        soundPickerDropDown:SetValue(1)
    end
    soundPickerDropDown:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    soundPickerDropDown:SetCallback("OnValueChanged", CTT_PlaySoundOnDropDownSelect)
    container:AddChild(soundPickerDropDown)
    container.soundPickerDropDown = soundPickerDropDown

    -- Dropdown for different options to show the tracker
    local instanceType = AceGUI:Create("Dropdown")
    instanceType:SetLabel(L["Show Tracker When?"])
    instanceType:SetWidth(150)
    instanceType:SetMultiselect(false)
    instanceType:ClearAllPoints()
    instanceType:SetList(instanceTypes)
    --TODO add conditionals to display the menu text as needed once list is made
    if db.profile.cttMenuOptions.instanceType ~= nil then
        instanceType:SetText(instanceTypes[db.profile.cttMenuOptions.instanceType])
        instanceType:SetValue(db.profile.cttMenuOptions.instanceType)
    else
        instanceType:SetText(instanceType[4])
        instanceType:SetValue(4)
    end
    instanceType:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    instanceType:SetCallback("OnValueChanged", CTT_InstanceTypeDropDown)
    container:AddChild(instanceType)
    container.instanceType = instanceType

    -- Editbox for entering profile name
    local profileName = AceGUI:Create("EditBox")
    profileName:SetLabel(L["New Profile Name"])
    profileName:ClearAllPoints()
    profileName:SetPoint("LEFT", container.tab, "LEFT", 10, 0)
    profileName:SetCallback("OnEnterPressed", CTT_ProfileNameOnEnterPressed)
    container:AddChild(profileName)
    container.profileName = profileName

    -- button to actually create the profile
    local profileAddButton = AceGUI:Create("Button")
    profileAddButton:SetText(L["Create Profile"])
    profileAddButton:SetWidth(125)
    profileAddButton:ClearAllPoints()
    profileAddButton:SetPoint("LEFT", container.tab, "LEFT", 6, 10)
    profileAddButton:SetCallback("OnClick", CTT_ProfileAddButton)
    container:AddChild(profileAddButton)
    container.profileAddButton = profileAddButton

    -- dropdown to choose from existing profiles
    local profileDropDownPicker = AceGUI:Create("Dropdown")
    profileDropDownPicker:SetLabel(L["Choose Profile"])
    profileDropDownPicker:SetMultiselect(false)
    profileDropDownPicker:ClearAllPoints()
    profileDropDownPicker:SetList(db:GetProfiles())

    profileDropDownPicker:SetValue(activeProfileKey)
    profileDropDownPicker:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    profileDropDownPicker:SetCallback("OnValueChanged", CTT_ProfileDropDownPicker)
    container:AddChild(profileDropDownPicker)
    container.profileDropDownPicker = profileDropDownPicker

    -- dropdown to copy settings from an existing profile to current profile
    local profileCopyDropdown = AceGUI:Create("Dropdown")
    profileCopyDropdown:SetLabel(L["Copy Profile"])
    profileCopyDropdown:SetMultiselect(false)
    profileCopyDropdown:ClearAllPoints()
    profileCopyDropdown:SetList(db:GetProfiles())
    profileCopyDropdown:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    profileCopyDropdown:SetCallback("OnValueChanged", CTT_ProfileCopyDropdown)
    container:AddChild(profileCopyDropdown)
    container.profileCopyDropdown = profileCopyDropdown

    -- dropdown to delete existing profiles
    local profileDeleteDropdown = AceGUI:Create("Dropdown")
    profileDeleteDropdown:SetLabel(L["Delete Profile"])
    profileDeleteDropdown:SetMultiselect(false)
    profileDeleteDropdown:ClearAllPoints()
    profileDeleteDropdown:SetList(db:GetProfiles())
    profileDeleteDropdown:SetPoint("LEFT", container.tab, "LEFT", 6, 0)
    profileDeleteDropdown:SetCallback("OnValueChanged", CTT_ProfileDeleteDropdown)
    container:AddChild(profileDeleteDropdown)
    container.profileDeleteDropdown = profileDeleteDropdown

end

-- function that draws the dungeons tab
local function Dungeons(container)
    local Label = AceGUI:Create("Label")
    Label:SetText(L["Feature Coming Soon!!"])
    Label:SetColor(255, 255, 0)
    -- Label:SetFontObject("GameFontNormal")
    -- Label:SetFont("Fonts\\MORPHEUS_CYR.TTF", 12, nil)
    Label:SetWidth(200)
    Label:ClearAllPoints()
    Label:SetPoint("LEFT", container.tab, "LEFT", 6, 10)
    container:AddChild(Label)
    container.Label = Label
end

-- function that draws the raid tab
local function Raids(container)
    --select xpac
    local xpacDropdown = AceGUI:Create("Dropdown")
    xpacDropdown:SetLabel(L["Expasion"])
    xpacDropdown:SetMultiselect(false)
    xpacDropdown:SetList(xpacs)
    xpacDropdown:SetText(xpacs[db.profile.cttMenuOptions.xpacKey])
    xpacDropdown:SetValue(db.profile.cttMenuOptions.xpacKey)
    xpacDropdown:SetWidth(125)
    xpacDropdown:ClearAllPoints()
    xpacDropdown:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 10)
    xpacDropdown:SetCallback("OnValueChanged", CTT_ExpansionDropDownForRaidTab)
    container:AddChild(xpacDropdown)
    container.xpacDropdown = xpacDropdown

    -- Select Raid
    local raidDropdown = AceGUI:Create("Dropdown")
    raidDropdown:SetLabel(L["Raid"])
    raidDropdown:SetMultiselect(false)
    raidDropdown:SetList(raidInstanceZones[db.profile.cttMenuOptions.xpacKey])
    raidDropdown:SetText(raidInstanceZones[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey])
    raidDropdown:SetValue(db.profile.cttMenuOptions.raidKey)
    raidDropdown:SetWidth(225)
    raidDropdown:ClearAllPoints()
    raidDropdown:SetPoint("LEFT", container.tab, "LEFT", 12, 10)
    raidDropdown:SetCallback("OnValueChanged", CTT_AlertRaidDropDownForRaidTab)
    container:AddChild(raidDropdown)
    container.raidDropdown = raidDropdown

    -- Select Boss
    local bossDropdown = AceGUI:Create("Dropdown")
    bossDropdown:SetLabel(L["Boss"])
    bossDropdown:SetMultiselect(false)
    bossDropdown:SetList(raidBosses[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey])
    bossDropdown:SetText(raidBosses[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey][
    db.profile.cttMenuOptions.bossDropDownkey])
    bossDropdown:SetValue(db.profile.cttMenuOptions.bossDropDownkey)
    bossDropdown:SetWidth(250)
    bossDropdown:ClearAllPoints()
    bossDropdown:SetPoint("LEFT", container.tab, "LEFT", 6, 10)
    bossDropdown:SetCallback("OnValueChanged", CTT_AlertBossDropDownForRaidTab)
    container:AddChild(bossDropdown)
    container.bossDropdown = bossDropdown

    -- Add alert to list
    local deleteKillsButton = AceGUI:Create("Button")
    deleteKillsButton:SetText(L["Clear All"])
    deleteKillsButton:SetWidth(125)
    deleteKillsButton:ClearAllPoints()
    deleteKillsButton:SetPoint("LEFT", container.tab, "LEFT", 6, 10)
    deleteKillsButton:SetCallback("OnClick", CTT_ClearAlertBossRaidTab)
    container:AddChild(deleteKillsButton)
    container.deleteKillsButton = deleteKillsButton

    -- scroll frame for timers
    scrollcontainer = AceGUI:Create("InlineGroup")
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetLayout("Fill")

    container:AddChild(scrollcontainer)

    scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetStatusTable(db.profile.RaidKills)
    scrollcontainer:AddChild(scroll)

    -- handle the scrollable alerts.
    if db.profile.RaidKills ~= nil and table.getn(db.profile.RaidKills) > 0 then
        for i, v in ipairs(db.profile.RaidKills) do
            if (v.Expansion == xpacs[db.profile.cttMenuOptions.xpacKey]
                and v.RaidInstance == raidInstanceZones[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey]
                and v.BossName == raidBosses[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey][db.profile.cttMenuOptions.bossDropDownkey])
                then
                    local value = "value" .. i
                    value = AceGUI:Create("Label")
                    value:SetText(v.BossName .. " was killed on: " .. v.LocalKillTime ..", with a Kill Time of: " .. v.KillTime.. ", raid difficulty: " .. v.Difficulty .. ", with " .. v.GroupSize .. " players" .. ", and was killed successfully: " .. tostring(v.Success))
                    value:SetColor(255, 255, 0)
                    if (table.getn(db.profile.RaidKills) > 10) then
                        value:SetWidth(600)
                    else
                        value:SetWidth(625)
                    end
                    value:ClearAllPoints()
                    value:SetPoint("LEFT", nil, "LEFT", 6, 10)
                    scroll:AddChild(value)
        
                    local deleteBtn = "btn" .. i
                    deleteBtn = AceGUI:Create("Button")
                    deleteBtn:SetText("X")
                    deleteBtn:SetWidth(40)
                    deleteBtn:ClearAllPoints()
                    deleteBtn:SetPoint("LEFT", nil, "LEFT", 6, 10)
                    deleteBtn:SetCallback("OnClick", function(widget) CTT_AlertDeleteButtonClickedForRaidTab(widget, event, i) end)
                    scroll:AddChild(deleteBtn) 
                end
        end
    end
end

-- function that draws the Alert Times tab
local function Alerts(container)
    --select xpac
    local xpacDropdown = AceGUI:Create("Dropdown")
    xpacDropdown:SetLabel(L["Expasion"])
    xpacDropdown:SetMultiselect(false)
    xpacDropdown:SetList(xpacs)
    xpacDropdown:SetText(xpacs[db.profile.cttMenuOptions.xpacKey])
    xpacDropdown:SetValue(db.profile.cttMenuOptions.xpacKey)
    xpacDropdown:SetWidth(125)
    xpacDropdown:ClearAllPoints()
    xpacDropdown:SetPoint("TOPLEFT", container.tab, "TOPLEFT", 6, 10)
    xpacDropdown:SetCallback("OnValueChanged", CTT_ExpansionDropDown)
    container:AddChild(xpacDropdown)
    container.xpacDropdown = xpacDropdown

    -- Input field to get the time (in seconds)
    local timeInput = AceGUI:Create("EditBox")
    timeInput:SetLabel(L["Time(sec)"])
    timeInput:SetWidth(85)
    timeInput:ClearAllPoints()
    if db.profile.cttMenuOptions.localStore ~= nil then timeInput:SetText(db.profile.cttMenuOptions.localStore) end
    timeInput:SetPoint("LEFT", container.tab, "LEFT", 6, 10)
    timeInput:SetCallback("OnEnterPressed", CTT_AlertTimeOnEnterPressed)
    container:AddChild(timeInput)
    container.timeInput = timeInput

    -- Select Raid
    local raidDropdown = AceGUI:Create("Dropdown")
    raidDropdown:SetLabel(L["Raid"])
    raidDropdown:SetMultiselect(false)
    raidDropdown:SetList(raidInstanceZones[db.profile.cttMenuOptions.xpacKey])
    raidDropdown:SetText(raidInstanceZones[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey])
    raidDropdown:SetValue(db.profile.cttMenuOptions.raidKey)
    raidDropdown:SetWidth(225)
    raidDropdown:ClearAllPoints()
    raidDropdown:SetPoint("LEFT", container.tab, "LEFT", 12, 10)
    raidDropdown:SetCallback("OnValueChanged", CTT_AlertRaidDropDown)
    container:AddChild(raidDropdown)
    container.raidDropdown = raidDropdown

    -- Select Boss
    local bossDropdown = AceGUI:Create("Dropdown")
    bossDropdown:SetLabel(L["Boss"])
    bossDropdown:SetMultiselect(false)
    bossDropdown:SetList(raidBosses[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey])
    bossDropdown:SetText(raidBosses[db.profile.cttMenuOptions.xpacKey][db.profile.cttMenuOptions.raidKey][
        db.profile.cttMenuOptions.bossDropDownkey])
    bossDropdown:SetValue(db.profile.cttMenuOptions.bossDropDownkey)
    bossDropdown:SetWidth(250)
    bossDropdown:ClearAllPoints()
    bossDropdown:SetPoint("LEFT", container.tab, "LEFT", 6, 10)
    bossDropdown:SetCallback("OnValueChanged", CTT_AlertBossDropDown)
    container:AddChild(bossDropdown)
    container.bossDropdown = bossDropdown

    -- Add alert to list
    local addAlertButton = AceGUI:Create("Button")
    addAlertButton:SetText(L["Add"])
    addAlertButton:SetWidth(75)
    addAlertButton:ClearAllPoints()
    addAlertButton:SetPoint("LEFT", container.tab, "LEFT", 6, 10)
    addAlertButton:SetCallback("OnClick", CTT_AlertAddButtonClicked)
    container:AddChild(addAlertButton)
    container.addAlertButton = addAlertButton

    -- scroll frame for timers
    scrollcontainer = AceGUI:Create("InlineGroup")
    scrollcontainer:SetFullWidth(true)
    scrollcontainer:SetFullHeight(true)
    scrollcontainer:SetLayout("Fill")

    container:AddChild(scrollcontainer)

    scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetStatusTable(db.profile.cttMenuOptions.alerts)
    scrollcontainer:AddChild(scroll)



    for i, v in ipairs(db.profile.cttMenuOptions.alerts) do
        local value = "value" .. i
        value = AceGUI:Create("Label")
        value:SetText(L["Seconds into fight: "] ..
            db.profile.cttMenuOptions.alerts[i][1] ..
            L[", Raid: "] .. db.profile.cttMenuOptions.alerts[i][2] .. L[", Boss: "] .. db.profile.cttMenuOptions.alerts[i][3])
        value:SetColor(255, 255, 0)
        -- value:SetFont("Fonts\\MORPHEUS_CYR.TTF", 10)
        if (table.getn(db.profile.cttMenuOptions.alerts) > 10) then
            value:SetWidth(600)
        else
            value:SetWidth(625)
        end
        value:ClearAllPoints()
        value:SetPoint("LEFT", nil, "LEFT", 6, 10)
        scroll:AddChild(value)

        local deleteBtn = "btn" .. i
        deleteBtn = AceGUI:Create("Button")
        deleteBtn:SetText("X")
        deleteBtn:SetWidth(40)
        deleteBtn:ClearAllPoints()
        deleteBtn:SetPoint("LEFT", nil, "LEFT", 6, 10)
        deleteBtn:SetCallback("OnClick", function(widget) CTT_AlertDeleteButtonClicked(widget, event, i) end)
        scroll:AddChild(deleteBtn)
    end
end

local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    db.profile.cttMenuOptions.selectedTab = group
    if group == "options" then
        OptionsMenu(container)
    elseif group == "dungeons" then
        Dungeons(container)
    elseif group == "raids" then
        Raids(container)
    elseif group == "alerts" then
        Alerts(container)
    end
end

function CTT:CreateOptionsMenu()
    -- main menu frame
    menu = AceGUI:Create("Frame")
    menu:SetTitle(L["Combat Time Tracker Options"])
    menu:SetStatusText(C_AddOns.GetAddOnMetadata("CombatTimeTracker", "Version"))
    menu:SetWidth(750)
    menu:SetHeight(750)
    menu:SetLayout("Fill")
    -- menu:SetCallBack("OnGroupSelected", CTT_SelectGroup)
    menu:Hide()
    CTT.menu = menu

    CTT_menu = menu.frame
    menu.frame:SetResizeBounds(750, 750, 750, 750)
    menu.frame:SetFrameStrata("HIGH")
    menu.frame:SetFrameLevel(1)

    -- Create the TabGroup
    local tab = AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    -- Setup which tabs to show
    tab:SetTabs({ { text = L["Options"], value = "options" }, { text = L["Dungeons"], value = "dungeons" },
        { text = L["Raids"], value = "raids" }, { text = L["Alert Times"], value = "alerts" } })
    -- Register callback
    tab:SetCallback("OnGroupSelected", SelectGroup)
    -- Set initial Tab (this will fire the OnGroupSelected callback)
    tab:SelectTab("options")

    -- add to the frame container
    menu:AddChild(tab)
    menu.tab = tab

    CTT.menu.tab:SelectTab(group)

    -- Add frame to the global variable table so that pressing escape key closes the menu frame
    _G["CombatTimeTrackerMenu"] = menu.frame
    tinsert(UISpecialFrames, "CombatTimeTrackerMenu")
end

--|-----------------------|
--|  CTT Debug Functions  |
--|-----------------------|

--[==[@debug@
--@end-debug@]==]
