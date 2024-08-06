-- Options.lua
-- Everything related to building/configuring options.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local scripts = Hekili.Scripts
local state = Hekili.State

local format, lower, match = string.format, string.lower, string.match
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe

local UnitBuff, UnitDebuff = ns.UnitBuff, ns.UnitDebuff

local callHook = ns.callHook

local SpaceOut = ns.SpaceOut

local formatKey, orderedPairs, tableCopy, GetItemInfo, RangeType = ns.formatKey, ns.orderedPairs, ns.tableCopy, ns.CachedGetItemInfo, ns.RangeType

-- Atlas/Textures
local AtlasToString, GetAtlasFile, GetAtlasCoords = ns.AtlasToString, ns.GetAtlasFile, ns.GetAtlasCoords

-- Options Functions
local TableToString, StringToTable, SerializeActionPack, DeserializeActionPack, SerializeDisplay, DeserializeDisplay, SerializeStyle, DeserializeStyle

local ACD = LibStub( "AceConfigDialog-3.0" )
local LDBIcon = LibStub( "LibDBIcon-1.0", true )
local LSM = LibStub( "LibSharedMedia-3.0" )
local SF = SpellFlashCore

local NewFeature = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0|t"
local GreenPlus = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus"
local RedX = "Interface\\AddOns\\Hekili\\Textures\\RedX"
local BlizzBlue = "|cFF00B4FF"
local Bullet = AtlasToString( "characterupdate_arrow-bullet-point" )
local ClassColor = C_ClassColor.GetClassColor( class.file )

local IsPassiveSpell = C_Spell.IsSpellPassive or _G.IsPassiveSpell
local IsHarmfulSpell = C_Spell.IsSpellHarmful or _G.IsHarmfulSpell
local IsHelpfulSpell = C_Spell.IsSpellHelpful or _G.IsHelpfulSpell
local IsPressHoldReleaseSpell = C_Spell.IsPressHoldReleaseSpell or _G.IsPressHoldReleaseSpell

local GetNumSpellTabs = C_SpellBook.GetNumSpellBookSkillLines;

local GetSpellTabInfo = function(index)
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(index);
    if skillLineInfo then
        return	skillLineInfo.name, 
                skillLineInfo.iconID, 
                skillLineInfo.itemIndexOffset, 
                skillLineInfo.numSpellBookItems, 
                skillLineInfo.isGuild, 
                skillLineInfo.offSpecID,
                skillLineInfo.shouldHide,
                skillLineInfo.specID;
    end
end

local GetSpellInfo = function( spellID )
    if not spellID then
        return nil;
    end

    local spellInfo = C_Spell.GetSpellInfo(spellID);
    if spellInfo then
        return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
    end
end

local GetSpellDescription = C_Spell.GetSpellDescription

local GetSpellCharges = function(spellID)
    local spellChargeInfo = C_Spell.GetSpellCharges(spellID);
    if spellChargeInfo then
        return spellChargeInfo.currentCharges, spellChargeInfo.maxCharges, spellChargeInfo.cooldownStartTime, spellChargeInfo.cooldownDuration, spellChargeInfo.chargeModRate;
    end
end


-- One Time Fixes
local oneTimeFixes = {
    resetAberrantPackageDates_20190728_1 = function( p )
        for _, v in pairs( p.packs ) do
            if type( v.date ) == 'string' then v.date = tonumber( v.date ) or 0 end
            if type( v.version ) == 'string' then v.date = tonumber( v.date ) or 0 end
            if v.date then while( v.date > 21000000 ) do v.date = v.date / 10 end end
            if v.version then while( v.version > 21000000 ) do v.version = v.version / 10 end end
        end
    end,

    --[[ forceEnableEnhancedRecheckBoomkin_20210712 = function( p )
        local s = rawget( p.specs, 102 )
        if s then s.enhancedRecheck = true end
    end, ]]

    updateMaxRefreshToNewSpecOptions_20220222 = function( p )
        for id, spec in pairs( p.specs ) do
            if spec.settings.maxRefresh then
                spec.settings.combatRefresh = 1 / spec.settings.maxRefresh
                spec.settings.regularRefresh = min( 1, 5 * spec.settings.combatRefresh )
                spec.settings.maxRefresh = nil
            end
        end
    end,

    forceEnableAllClassesOnceDueToBug_20220225 = function( p )
        for id, spec in pairs( p.specs ) do
            spec.enabled = true
        end
    end,

    forceReloadAllDefaultPriorities_20220228 = function( p )
        for name, pack in pairs( p.packs ) do
            if pack.builtIn then
                Hekili.DB.profile.packs[ name ] = nil
                Hekili:RestoreDefault( name )
            end
        end
    end,

    forceReloadClassDefaultOptions_20220306 = function( p )
        local sendMsg = false
        for spec, data in pairs( class.specs ) do
            if spec > 0 and not p.runOnce[ 'forceReloadClassDefaultOptions_20220306_' .. spec ] then
                local cfg = p.specs[ spec ]
                for k, v in pairs( data.options ) do
                    if cfg[ k ] == ns.specTemplate[ k ] and cfg[ k ] ~= v then
                        cfg[ k ] = v
                        sendMsg = true
                    end
                end
                p.runOnce[ 'forceReloadClassDefaultOptions_20220306_' .. spec ] = true
            end
        end
        if sendMsg then
            C_Timer.After( 5, function()
                if Hekili.DB.profile.notifications.enabled then Hekili:Notify( "一些專精選項已經重置。", 6 ) end
                Hekili:Print( "一些專精選項已經重置為預設值，每個設定檔/專精可能都會發生一次。" )
            end )
        end
        p.runOnce.forceReloadClassDefaultOptions_20220306 = nil
    end,

    forceDeleteBrokenMultiDisplay_20220319 = function( p )
        if rawget( p.displays, "Multi" ) then
            p.displays.Multi = nil
        end

        p.runOnce.forceDeleteBrokenMultiDisplay_20220319 = nil
    end,

    forceSpellFlashBrightness_20221030 = function( p )
        for display, data in pairs( p.displays ) do
            if data.flash and data.flash.brightness and data.flash.brightness > 100 then
                data.flash.brightness = 100
            end
        end
    end,

    fixHavocPriorityVersion_20240805 = function( p )
        local havoc = p.packs[ "Havoc" ]
        if havoc and ( havoc.date == 20270727 or havoc.version == 20270727 ) then
            havoc.date = 20240727
            havoc.version = 20240727
        end
    end,
  }


function Hekili:RunOneTimeFixes()
    local profile = Hekili.DB.profile
    if not profile then return end

    profile.runOnce = profile.runOnce or {}

    for k, v in pairs( oneTimeFixes ) do
        if not profile.runOnce[ k ] then
            profile.runOnce[k] = true
            local ok, err = pcall( v, profile )
            if err then
                Hekili:Error( "一次性更新失敗: " .. k .. ": " .. err )
                profile.runOnce[ k ] = nil
            end
        end
    end
end


-- Display Controls
--    Single Display -- single vs. auto in one display.
--    Dual Display   -- single in one display, aoe in another.
--    Hybrid Display -- automatic in one display, can toggle to single/AOE.

local displayTemplate = {
    enabled = true,

    numIcons = 4,
    forecastPeriod = 15,

    primaryWidth = 50,
    primaryHeight = 50,

    keepAspectRatio = true,
    zoom = 30,

    frameStrata = "LOW",
    frameLevel = 10,

    elvuiCooldown = false,
    hideOmniCC = false,

    queue = {
        anchor = 'RIGHT',
        direction = 'RIGHT',
        style = 'RIGHT',
        alignment = 'CENTER',

        width = 50,
        height = 50,

        -- offset = 5, -- deprecated.
        offsetX = 5,
        offsetY = 0,
        spacing = 5,

        elvuiCooldown = false,

        --[[ font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE" ]]
    },

    visibility = {
        advanced = false,

        mode = {
            aoe = true,
            automatic = true,
            dual = true,
            single = true,
            reactive = true,
        },

        pve = {
            alpha = 1,
            always = 1,
            target = 1,
            combat = 1,
            combatTarget = 1,
            hideMounted = false,
        },

        pvp = {
            alpha = 1,
            always = 1,
            target = 1,
            combat = 1,
            combatTarget = 1,
            hideMounted = false,
        },
    },

    border = {
        enabled = true,
        thickness = 1,
        fit = false,
        coloring = 'custom',
        color = { 0, 0, 0, 1 },
    },

    range = {
        enabled = true,
        type = 'ability',
    },

    glow = {
        enabled = false,
        queued = false,
        mode = "autocast",
        coloring = "default",
        color = { 0.95, 0.95, 0.32, 1 },

        highlight = true
    },

    flash = {
        enabled = false,
        color = { 255/255, 215/255, 0, 1 }, -- gold.
        blink = false,
        suppress = false,
        combat = false,

        size = 240,
        brightness = 100,
        speed = 0.4,

        fixedSize = false,
        fixedBrightness = false
    },

    captions = {
        enabled = false,
        queued = false,

        align = "CENTER",
        anchor = "BOTTOM",
        x = 0,
        y = 0,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE",

        color = { 1, 1, 1, 1 },
    },

    empowerment = {
        enabled = true,
        queued = true,
        glow = true,

        align = "CENTER",
        anchor = "BOTTOM",
        x = 0,
        y = 1,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 16,
        fontStyle = "THICKOUTLINE",

        color = { 1, 0.8196079, 0, 1 },
    },

    indicators = {
        enabled = true,
        queued = true,

        anchor = "RIGHT",
        x = 0,
        y = 0,
    },

    targets = {
        enabled = true,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE",

        anchor = "BOTTOMRIGHT",
        x = 0,
        y = 0,

        color = { 1, 1, 1, 1 },
    },

    delays = {
        type = "__NA",
        fade = false,
        extend = true,
        elvuiCooldowns = false,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE",

        anchor = "TOPLEFT",
        x = 0,
        y = 0,

        color = { 1, 1, 1, 1 },
    },

    keybindings = {
        enabled = true,
        queued = true,

        font = ElvUI and "PT Sans Narrow" or "Arial Narrow",
        fontSize = 12,
        fontStyle = "OUTLINE",

        lowercase = false,

        separateQueueStyle = false,

        queuedFont = ElvUI and "PT Sans Narrow" or "Arial Narrow",
        queuedFontSize = 12,
        queuedFontStyle = "OUTLINE",

        queuedLowercase = false,

        anchor = "TOPRIGHT",
        x = 1,
        y = -1,

        cPortOverride = true,
        cPortZoom = 0.6,

        color = { 1, 1, 1, 1 },
        queuedColor = { 1, 1, 1, 1 },
    },

}


local actionTemplate = {
    action = "heart_essence",
    enabled = true,
    criteria = "",
    caption = "",
    description = "",

    -- Shared Modifiers
    early_chain_if = "",  -- NYI

    cycle_targets = 0,
    max_cycle_targets = 3,
    max_energy = 0,

    interrupt = 0,  --NYI
    interrupt_if = "",  --NYI
    interrupt_immediate = 0,  -- NYI

    travel_speed = nil,

    enable_moving = false,
    moving = nil,
    sync = "",

    use_while_casting = 0,
    use_off_gcd = 0,
    only_cwc = 0,

    wait_on_ready = 0, -- NYI

    -- Call/Run Action List
    list_name = nil,
    strict = nil,

    -- Pool Resource
    wait = "0.5",
    for_next = 0,
    extra_amount = "0",

    -- Variable
    op = "set",
    condition = "",
    default = "",
    value = "",
    value_else = "",
    var_name = "unnamed",

    -- Wait
    sec = "1",
}


local packTemplate = {
    spec = 0,
    builtIn = false,

    author = UnitName("player"),
    desc = "這是 Hekili 輸出助手的動作列表包。",
    source = "",
    date = tonumber( date("%Y%M%D.%H%M") ),
    warnings = "",

    hidden = false,

    lists = {
        precombat = {
            {
                enabled = false,
                action = "heart_essence",
            },
        },
        default = {
            {
                enabled = false,
                action = "heart_essence",
            },
        },
    }
}

local specTemplate = ns.specTemplate


do
    local defaults

    -- Default Table
    function Hekili:GetDefaults()
        defaults = defaults or {
            global = {
                styles = {},
            },

            profile = {
                enabled = true,
                minimapIcon = false,
                autoSnapshot = true,
                screenshot = true,

                flashTexture = "Interface\\Cooldown\\star4",

                toggles = {
                    pause = {
                        key = "ALT-SHIFT-P",
                    },

                    snapshot = {
                        key = "ALT-SHIFT-[",
                    },

                    mode = {
                        key = "ALT-SHIFT-N",
                        -- type = "AutoSingle",
                        automatic = true,
                        single = true,
                        value = "automatic",
                    },

                    cooldowns = {
                        key = "ALT-SHIFT-R",
                        value = true,
                        override = false,
                        separate = false,
                    },

                    defensives = {
                        key = "ALT-SHIFT-T",
                        value = true,
                        separate = false,
                    },

                    potions = {
                        key = "",
                        value = false,
                    },

                    interrupts = {
                        key = "ALT-SHIFT-I",
                        value = true,
                        separate = false,
                    },

                    essences = {
                        key = "ALT-SHIFT-G",
                        value = true,
                        override = true,
                    },

                    custom1 = {
                        key = "",
                        value = false,
                        name = "自訂 #1"
                    },

                    custom2 = {
                        key = "",
                        value = false,
                        name = "自訂 #2"
                    }
                },

                specs = {
                    ['**'] = specTemplate
                },

                packs = {
                    ['**'] = packTemplate
                },

                notifications = {
                    enabled = true,

                    x = 0,
                    y = 0,

                    font = ElvUI and "Expressway" or "Arial Narrow",
                    fontSize = 20,
                    fontStyle = "OUTLINE",
                    color = { 1, 1, 1, 1 },

                    width = 600,
                    height = 40,
                },

                displays = {
                    Primary = {
                        enabled = true,
                        builtIn = true,

                        name = "Primary",

                        relativeTo = "SCREEN",
                        displayPoint = "TOP",
                        anchorPoint = "BOTTOM",

                        x = 0,
                        y = -225,

                        numIcons = 3,
                        order = 1,

                        flash = {
                            color = { 1, 0, 0, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast"
                        },
                    },

                    AOE = {
                        enabled = true,
                        builtIn = true,

                        name = "AOE",

                        x = 0,
                        y = -170,

                        numIcons = 3,
                        order = 2,

                        flash = {
                            color = { 0, 1, 0, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    Cooldowns = {
                        enabled = true,
                        builtIn = true,

                        name = "Cooldowns",
                        filter = 'cooldowns',

                        x = 0,
                        y = -280,

                        numIcons = 1,
                        order = 3,

                        flash = {
                            color = { 1, 0.82, 0, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    Defensives = {
                        enabled = true,
                        builtIn = true,

                        name = "Defensives",
                        filter = 'defensives',

                        x = -110,
                        y = -225,

                        numIcons = 1,
                        order = 4,

                        flash = {
                            color = { 0.522, 0.302, 1, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    Interrupts = {
                        enabled = true,
                        builtIn = true,

                        name = "Interrupts",
                        filter = 'interrupts',

                        x = -55,
                        y = -225,

                        numIcons = 1,
                        order = 5,

                        flash = {
                            color = { 1, 1, 1, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    ['**'] = displayTemplate
                },

                -- STILL NEED TO REVISE.
                Clash = 0,
                -- (above)

                runOnce = {
                },

                clashes = {
                },
                trinkets = {
                    ['**'] = {
                        disabled = false,
                        minimum = 0,
                        maximum = 0,
                    }
                },

                interrupts = {
                    pvp = {},
                    encounters = {},
                },

                filterCasts = true,
                castFilters = {
                    [75713] = {
                        desc = "Shadowmoon Burial Grounds - Shadowmoon Bone-Mender",
                        [152818] = "Shadow Mend",
                    },
                    [76057] = {
                        desc = "Shadowmoon Burial Grounds - Carrion Worm",
                        [153395] = "Body Slam",
                    },
                    [75459] = {
                        desc = "Shadowmoon Burial Grounds - Plagued Bat",
                        [153524] = "Plague Spit",
                    },
                    [76446] = {
                        desc = "Shadowmoon Burial Grounds - Shadowmoon Dominator",
                        [156776] = "Rending Voidlash",
                    },
                    [81820] = {
                        desc = "The Everbloom - Everbloom Mender",
                        [164887] = "Healing Waters",
                        [164965] = "Choking Vines",
                    },
                    [81819] = {
                        desc = "The Everbloom - Everbloom Naturalist",
                        [164965] = "Choking Vines",
                    },
                    [81985] = {
                        desc = "The Everbloom - Everbloom Cultivator",
                        [165213] = "Enraged Growth",
                    },
                    [83892] = {
                        desc = "The Everbloom - Life Warden Gola",
                        [168082] = "Revitalize",
                    },
                    [84957] = {
                        desc = "The Everbloom - Putrid Pyromancer",
                        [169839] = "Pyroblast",
                    },
                    [97197] = {
                        desc = "Halls of Valor - Valarjar Purifier",
                        [192563] = "Cleansing Flames",
                    },
                    [95769] = {
                        desc = "Darkheart Thicket - Mindshattered Screecher",
                        [200630] = "Unnerving Screech",
                    },
                    [100527] = {
                        desc = "Darkheart Thicket - Dreadfire Imp",
                        [201399] = "Dread Inferno",
                    },
                    [91006] = {
                        desc = "Neltharion's Lair - Rockback Gnasher",
                        [202181] = "Stone Gaze",
                    },
                    [101991] = {
                        desc = "Darkheart Thicket - Nightmare Dweller",
                        [204243] = "Tormenting Eye",
                    },
                    [104274] = {
                        desc = "Court of Stars - Baalgar the Watchful",
                        [207980] = "Disintegration Beam",
                    },
                    [104247] = {
                        desc = "Court of Stars - Duskwatch Arcanist",
                        [209410] = "Nightfall Orb",
                    },
                    [104270] = {
                        desc = "Court of Stars - Guardian Construct",
                        [209413] = "Suppress",
                        [225100] = "Charging Station",
                    },
                    [104295] = {
                        desc = "Court of Stars - Blazing Imp",
                        [211401] = "Drifting Embers",
                    },
                    [104300] = {
                        desc = "Court of Stars - Shadow Mistress",
                        [211470] = "Bewitch",
                    },
                    [95834] = {
                        desc = "Halls of Valor - Valarjar Mystic",
                        [215433] = "Holy Radiance",
                    },
                    [100532] = {
                        desc = "Darkheart Thicket - Bloodtainted Burster",
                        [225562] = "Blood Metamorphosis",
                    },
                    [102788] = {
                        desc = "Black Rook Hold - Felspite Dominator",
                        [227913] = "Felfrenzy",
                    },
                    [122986] = {
                        desc = "Atal'Dazar - Wild Skyscreamer",
                        [255041] = "Terrifying Screech",
                    },
                    [128434] = {
                        desc = "Atal'Dazar - Feasting Skyscreamer",
                        [255041] = "Terrifying Screech",
                    },
                    [129788] = {
                        desc = "Freehold - Irontide Bonesaw",
                        [257397] = "Healing Balm",
                    },
                    [126919] = {
                        desc = "Freehold - Irontide Stormcaller",
                        [257736] = "Thundering Squall",
                    },
                    [129600] = {
                        desc = "Freehold - Bilge Rat Brinescale",
                        [257784] = "Frost Blast",
                    },
                    [122965] = {
                        desc = "Atal'Dazar - Vol'kaal",
                        [259572] = "Noxious Stench",
                    },
                    [133379] = {
                        desc = "Temple of Sethraliss - Adderis",
                        [263365] = "A Peal of Thunder",
                    },
                    [131812] = {
                        desc = "Waycrest Manor - Heartsbane Soulcharmer",
                        [263959] = "Soul Volley",
                    },
                    [131685] = {
                        desc = "Waycrest Manor - Runic Disciple",
                        [264390] = "Spellbind",
                    },
                    [131821] = {
                        desc = "Waycrest Manor - Faceless Maiden",
                        [264407] = "Horrific Visage",
                    },
                    [131492] = {
                        desc = "The Underrot - Devout Blood Priest",
                        [265089] = "Dark Reconstitution",
                        [265091] = "Gift of G'huun",
                    },
                    [135049] = {
                        desc = "Waycrest Manor - Dreadwing Raven",
                        [265346] = "Pallid Glare",
                    },
                    [133912] = {
                        desc = "The Underrot - Bloodsworn Defiler",
                        [265433] = "Withering Curse",
                        [265523] = "Summon Spirit Drain Totem",
                    },
                    [134112] = {
                        desc = "Waycrest Manor - Matron Christiane",
                        [265876] = "Ruinous Volley",
                    },
                    [135365] = {
                        desc = "Waycrest Manor - Matron Alma",
                        [265876] = "Ruinous Volley",
                    },
                    [133835] = {
                        desc = "The Underrot - Feral Bloodswarmer",
                        [266106] = "Sonic Screech",
                    },
                    [134284] = {
                        desc = "The Underrot - Fallen Deathspeaker",
                        [266209] = "Wicked Frenzy",
                        [272183] = "Raise Dead",
                    },
                    [131864] = {
                        desc = "Waycrest Manor - Gorak Tul",
                        [266225] = "Darkened Lightning",
                    },
                    [137830] = {
                        desc = "Waycrest Manor - Pallid Gorger",
                        [271174] = "Retch",
                    },
                    [134024] = {
                        desc = "Waycrest Manor - Devouring Maggot",
                        [278444] = "Infest",
                    },
                    [142587] = {
                        desc = "Waycrest Manor - Devouring Maggot",
                        [278444] = "Infest",
                    },
                    [133685] = {
                        desc = "The Underrot - Befouled Spirit",
                        [278755] = "Harrowing Despair",
                    },
                    [122969] = {
                        desc = "Atal'Dazar - Zanchuli Witch-Doctor",
                        [279118] = "Unstable Hex",
                    },
                    [170044] = {
                        desc = "Maldraxxus - Venthyr Apprentice",
                        [345202] = "Absolution",
                    },
                    [185529] = {
                        desc = "Brackenhide Hollow - Bracken Warscourge",
                        [367500] = "Hideous Cackle",
                    },
                    [193178] = {
                        desc = "The Azure Span - Blightfur",
                        [367500] = "Hideous Cackle",
                    },
                    [195135] = {
                        desc = "Brackenhide Hollow - Bracken Warscourge",
                        [367500] = "Hideous Cackle",
                    },
                    [186191] = {
                        desc = "Brackenhide Hollow - Decay Speaker",
                        [367503] = "Withering Burst",
                        [382474] = "Decay Surge",
                    },
                    [184132] = {
                        desc = "Uldaman - Earthen Warder",
                        [369365] = "Curse of Stone",
                    },
                    [184301] = {
                        desc = "Uldaman - Cavern Seeker",
                        [369411] = "Sonic Burst",
                    },
                    [186420] = {
                        desc = "Uldaman - Earthen Weaver",
                        [369465] = "Hail of Stone",
                    },
                    [184580] = {
                        desc = "Uldaman - Olaf",
                        [369602] = "Defensive Bulwark",
                    },
                    [204046] = {
                        desc = "Valdrakken - Olaf",
                        [369602] = "Defensive Bulwark",
                    },
                    [184022] = {
                        desc = "Uldaman - Stonevault Geomancer",
                        [369675] = "Chain Lightning",
                    },
                    [186658] = {
                        desc = "Uldaman - Stonevault Geomancer",
                        [369675] = "Chain Lightning",
                    },
                    [189265] = {
                        desc = "Neltharus - Qalashi Bonetender",
                        [372223] = "Mending Clay",
                    },
                    [189470] = {
                        desc = "Neltharus - Lava Flare",
                        [372538] = "Melt",
                    },
                    [186220] = {
                        desc = "Brackenhide Hollow - Brackenhide Shaper",
                        [372711] = "Infuse Corruption",
                    },
                    [188067] = {
                        desc = "Ruby Life Pools - Flashfrost Chillweaver",
                        [372743] = "Ice Shield",
                    },
                    [189886] = {
                        desc = "Ruby Life Pools - Blazebound Firestorm",
                        [373017] = "Roaring Blaze",
                    },
                    [193462] = {
                        desc = "The Nokhud Offensive - Batak",
                        [373395] = "Bloodcurdling Shout",
                    },
                    [199717] = {
                        desc = "The Nokhud Offensive - Nokhud Defender",
                        [373395] = "Bloodcurdling Shout",
                    },
                    [190342] = {
                        desc = "Halls of Infusion - Containment Apparatus",
                        [374045] = "Expulse",
                    },
                    [190345] = {
                        desc = "Halls of Infusion - Primalist Geomancer",
                        [374066] = "Earth Shield",
                    },
                    [190348] = {
                        desc = "Halls of Infusion - Primalist Ravager",
                        [374080] = "Blasting Gust",
                    },
                    [190340] = {
                        desc = "Halls of Infusion - Refti Defender",
                        [374339] = "Demoralizing Shout",
                    },
                    [186226] = {
                        desc = "Brackenhide Hollow - Fetid Rotsinger",
                        [374544] = "Burst of Decay",
                    },
                    [190362] = {
                        desc = "Halls of Infusion - Dazzling Dragonfly",
                        [374563] = "Dazzle",
                    },
                    [190368] = {
                        desc = "Halls of Infusion - Flamecaller Aymi",
                        [374699] = "Cauterize",
                        [374706] = "Pyretic Burst",
                    },
                    [191164] = {
                        desc = "The Azure Vault - Arcane Tender",
                        [375596] = "Erratic Growth",
                    },
                    [196115] = {
                        desc = "The Azure Vault - Arcane Tender",
                        [375596] = "Erratic Growth",
                    },
                    [190377] = {
                        desc = "Halls of Infusion - Primalist Icecaller",
                        [376171] = "Refreshing Tides",
                    },
                    [189901] = {
                        desc = "Neltharus - Warlord Sargha",
                        [376780] = "Magma Shield",
                    },
                    [190407] = {
                        desc = "Halls of Infusion - Aqua Rager",
                        [377341] = "Tidal Divergence",
                    },
                    [192333] = {
                        desc = "Algeth'ar Academy - Alpha Eagle",
                        [377389] = "Call of the Flock",
                    },
                    [190405] = {
                        desc = "Halls of Infusion - Infuser Sariya",
                        [377402] = "Aqueous Barrier",
                    },
                    [187155] = {
                        desc = "The Azure Vault - Rune Seal Keeper",
                        [377488] = "Icy Bindings",
                    },
                    [184335] = {
                        desc = "Uldaman - Infinite Agent",
                        [377500] = "Hasten",
                    },
                    [186125] = {
                        desc = "Brackenhide Hollow - Tricktotem",
                        [377950] = "Greater Healing Rapids",
                    },
                    [192788] = {
                        desc = "Neltharus - Qalashi Thaumaturge",
                        [378282] = "Molten Core",
                    },
                    [184300] = {
                        desc = "Uldaman - Ebonstone Golem",
                        [381593] = "Thunderous Clap",
                    },
                    [185528] = {
                        desc = "Brackenhide Hollow - Trickclaw Mystic",
                        [382249] = "Earth Bolt",
                    },
                    [185656] = {
                        desc = "Brackenhide Hollow - Filth Caller",
                        [382474] = "Decay Surge",
                    },
                    [187315] = {
                        desc = "Brackenhide Hollow - Disease Slasher",
                        [382787] = "Decay Claws",
                    },
                    [194467] = {
                        desc = "Brackenhide Hollow - Brackenhide Slasher",
                        [382787] = "Decay Claws",
                    },
                    [193944] = {
                        desc = "Neltharus - Qalashi Lavamancer",
                        [382791] = "Molten Barrier",
                    },
                    [189464] = {
                        desc = "Neltharus - Qalashi Irontorch",
                        [384161] = "Mote of Combustion",
                    },
                    [190207] = {
                        desc = "Ruby Life Pools - Primalist Cinderweaver",
                        [384194] = "Cinderbolt",
                    },
                    [191847] = {
                        desc = "The Nokhud Offensive - Nokhud Plainstomper",
                        [384365] = "Disruptive Shout",
                    },
                    [192800] = {
                        desc = "The Nokhud Offensive - Nokhud Lancemaster",
                        [384365] = "Disruptive Shout",
                    },
                    [197650] = {
                        desc = "Ohn'ahran Plains - Tarolekk, the Stomper",
                        [384365] = "Disruptive Shout",
                    },
                    [186116] = {
                        desc = "Brackenhide Hollow - Gutshot",
                        [384633] = "Master's Call",
                    },
                    [186339] = {
                        desc = "The Nokhud Offensive - Teera",
                        [384808] = "Guardian Wind",
                    },
                    [186246] = {
                        desc = "Brackenhide Hollow - Fleshripper Vulture",
                        [385029] = "Screech",
                    },
                    [194894] = {
                        desc = "The Nokhud Offensive - Primalist Stormspeaker",
                        [386015] = "Summon Squall",
                        [386024] = "Tempest",
                        [386025] = "Tempest",
                    },
                    [186741] = {
                        desc = "The Azure Vault - Arcane Elemental",
                        [386546] = "Waking Bane",
                    },
                    [195696] = {
                        desc = "The Nokhud Offensive - Primalist Thunderbeast",
                        [387125] = "Thunderstrike",
                    },
                    [195927] = {
                        desc = "The Nokhud Offensive - Soulharvester Galtmaa",
                        [387411] = "Death Bolt Volley",
                    },
                    [195928] = {
                        desc = "The Nokhud Offensive - Soulharvester Duuren",
                        [387411] = "Death Bolt Volley",
                    },
                    [195929] = {
                        desc = "The Nokhud Offensive - Soulharvester Tumen",
                        [387411] = "Death Bolt Volley",
                    },
                    [195930] = {
                        desc = "The Nokhud Offensive - Soulharvester Mandakh",
                        [387411] = "Death Bolt Volley",
                    },
                    [196102] = {
                        desc = "The Azure Vault - Conjured Lasher",
                        [387564] = "Mystic Vapors",
                    },
                    [195877] = {
                        desc = "The Nokhud Offensive - Risen Mystic",
                        [387596] = "Swift Wind",
                    },
                    [196203] = {
                        desc = "Algeth'ar Academy - Ethereal Restorer",
                        [387955] = "Celestial Shield",
                    },
                    [196044] = {
                        desc = "Algeth'ar Academy - Unruly Textbook",
                        [388392] = "Monotonous Lecture",
                    },
                    [196045] = {
                        desc = "Algeth'ar Academy - Corrupted Manafiend",
                        [388862] = "Surge",
                        [388863] = "Mana Void",
                    },
                    [197985] = {
                        desc = "Ruby Life Pools - Flame Channeler",
                        [392451] = "Flashfire",
                    },
                    [197535] = {
                        desc = "Ruby Life Pools - High Channeler Ryvati",
                        [392924] = "Shock Blast",
                    },
                    [189235] = {
                        desc = "Neltharus - Overseer Lahar",
                        [395427] = "Burning Roar",
                    },
                    [199037] = {
                        desc = "Halls of Infusion - Primalist Shocktrooper",
                        [395694] = "Elemental Focus",
                    },
                    [59555] = {
                        desc = "Temple of the Jade Serpent - Haunting Sha",
                        [395859] = "Haunting Scream",
                    },
                    [59546] = {
                        desc = "Temple of the Jade Serpent - The Talking Fish",
                        [395872] = "Sleepy Soliloquy",
                    },
                    [59552] = {
                        desc = "Temple of the Jade Serpent - The Crybaby Hozen",
                        [396018] = "Fit of Rage",
                    },
                    [59544] = {
                        desc = "Temple of the Jade Serpent - The Nodding Tiger",
                        [396073] = "Cat Nap",
                    },
                    [196548] = {
                        desc = "Algeth'ar Academy - Ancient Branch",
                        [396640] = "Healing Touch",
                    },
                    [196576] = {
                        desc = "Algeth'ar Academy - Spellbound Scepter",
                        [396812] = "Mystic Blast",
                    },
                    [193373] = {
                        desc = "The Nokhud Offensive - Nokhud Thunderfist",
                        [397394] = "Deadly Thunder",
                    },
                    [200126] = {
                        desc = "Temple of the Jade Serpent - Fallen Waterspeaker",
                        [397889] = "Tidal Burst",
                    },
                    [200137] = {
                        desc = "Temple of the Jade Serpent - Depraved Mistweaver",
                        [397914] = "Defiling Mist",
                    },
                    [75979] = {
                        desc = "Shadowmoon Burial Grounds - Exhumed Spirit",
                        [398206] = "Death Blast",
                    },
                    [204206] = {
                        desc = "Dawn of the Infinite - Horde Farseer",
                        [407891] = "Healing Wave",
                    },
                    [45912] = {
                        desc = "The Vortex Pinnacle - Wild Vortex",
                        [410870] = "Cyclone",
                    },
                    [205363] = {
                        desc = "Dawn of the Infinite - Time-Lost Waveshaper",
                        [411300] = "Fish Bolt Volley",
                    },
                    [205727] = {
                        desc = "Dawn of the Infinite - Time-Lost Rocketeer",
                        [412233] = "Rocket Bolt Volley",
                    },
                    [205337] = {
                        desc = "Dawn of the Infinite - Infinite Timebender",
                        [412378] = "Dizzying Sands",
                    },
                    [205158] = {
                        desc = "Dawn of the Infinite - Spurlok, Timesworn Sentinel",
                        [412922] = "Binding Grasp",
                    },
                    [138187] = {
                        desc = "The Underrot - Grotesque Horror",
                        [413044] = "Dark Echoes",
                    },
                    [201223] = {
                        desc = "Dawn of the Infinite - Infinite Twilight Magus",
                        [413607] = "Corroding Volley",
                    },
                    [206066] = {
                        desc = "Dawn of the Infinite - Timestream Leech",
                        [415437] = "Enervate",
                    },
                    [206140] = {
                        desc = "Dawn of the Infinite - Coalesced Time",
                        [415770] = "Infinite Bolt Volley",
                    },
                    [199000] = {
                        desc = "Dawn of the Infinite - Chrono-Lord Deios",
                        [416139] = "Temporal Breath",
                    },
                    [199748] = {
                        desc = "Dawn of the Infinite - Timeline Marauder",
                        [417481] = "Displace Chronosequence",
                    },
                    [208698] = {
                        desc = "Dawn of the Infinite - Infinite Riftmage",
                        [418200] = "Infinite Burn",
                    },
                    [83893] = {
                        desc = "The Everbloom - Earthshaper Telu",
                        [427460] = "Toxic Bloom",
                    },
                    [40943] = {
                        desc = "Throne of the Tides - Gilgoblin Aquamage",
                        [429176] = "Aquablast",
                    },

                    [187771] = {
                        desc = "Vault of the Incarnates - Kadros Icewrath",
                        [372315] = "Frost Spike",
                    },
                    [187768] = {
                        desc = "Vault of the Incarnates - Dathea Stormlash",
                        [372394] = "Lightning Bolt",
                    },
                    [190686] = {
                        desc = "Vault of the Incarnates - Frozen Destroyer",
                        [374623] = "Frost Binds",
                    },
                    [191232] = {
                        desc = "Vault of the Incarnates - Drakonid Stormbringer",
                        [375653] = "Static Jolt",
                    },
                    [191206] = {
                        desc = "Vault of the Incarnates - Primalist Mage",
                        [375716] = "Ice Barrage",
                    },
                    [194647] = {
                        desc = "Vault of the Incarnates - Thunder Caller",
                        [384273] = "Storm Bolt",
                    },
                    [194990] = {
                        desc = "Vault of the Incarnates - Stormseeker Acolyte",
                        [385553] = "Storm Bolt",
                    },
                    [199233] = {
                        desc = "Vault of the Incarnates - Flamescale Captain",
                        [396040] = "Pyroblast",
                    },
                    [199703] = {
                        desc = "Aberrus, the Shadowed Crucible - Magma Mystic",
                        [397386] = "Lava Bolt",
                    },
                    [202971] = {
                        desc = "Aberrus, the Shadowed Crucible - Null Glimmer",
                        [404754] = "Blasting Scream",
                    },
                    [201288] = {
                        desc = "Aberrus, the Shadowed Crucible - Sundered Champion",
                        [406911] = "Brutal Cauterization",
                    },
                    [205619] = {
                        desc = "Aberrus, the Shadowed Crucible - Sarek Cinderbreath",
                        [406911] = "Brutal Cauterization",
                    },
                    [202969] = {
                        desc = "Aberrus, the Shadowed Crucible - Empty Recollection",
                        [411302] = "Cosmic Volley",
                    },
                    [210290] = {
                        desc = "Amirdrassil, the Dream's Hope - Firelands Flameguard",
                        [425381] = "Blazing Pulse",
                    },
                    [211904] = {
                        desc = "Amirdrassil, the Dream's Hope - Tainted Treant",
                        [425816] = "Blazing Pollen",
                    },
                    [210423] = {
                        desc = "Amirdrassil, the Dream's Hope - Keeper of the Dream",
                        [425995] = "Tranquility",
                    },
                    [208459] = {
                        desc = "Amirdrassil, the Dream's Hope - Fiery Treant",
                        [426524] = "Fiery Flourish",
                    },
                },

                iconStore = {
                    hide = false,
                },
            },
        }

        for id, spec in pairs( class.specs ) do
            if id > 0 then
                defaults.profile.specs[ id ] = defaults.profile.specs[ id ] or tableCopy( specTemplate )
                for k, v in pairs( spec.options ) do
                    defaults.profile.specs[ id ][ k ] = v
                end
            end
        end

        return defaults
    end
end


do
    local shareDB = {
        displays = {},
        styleName = "",
        export = "",
        exportStage = 0,

        import = "",
        imported = {},
        importStage = 0
    }

    function Hekili:GetDisplayShareOption( info )
        local n = #info
        local option = info[ n ]

        if shareDB[ option ] then return shareDB[ option ] end
        return shareDB.displays[ option ]
    end


    function Hekili:SetDisplayShareOption( info, val, v2, v3, v4 )
        local n = #info
        local option = info[ n ]

        if type(val) == 'string' then val = val:trim() end
        if shareDB[ option ] then shareDB[ option ] = val; return end

        shareDB.displays[ option ] = val
        shareDB.export = ""
    end



    local multiDisplays = {
        Primary = true,
        AOE = true,
        Cooldowns = false,
        Defensives = false,
        Interrupts = false,
    }

    local frameStratas = ns.FrameStratas

    -- Display Config.
    function Hekili:GetDisplayOption( info )
        local n = #info
        local display, category, option = info[ 2 ], info[ 3 ], info[ n ]

        if category == "shareDisplays" then
            return self:GetDisplayShareOption( info )
        end

        local conf = self.DB.profile.displays[ display ]

        if category ~= option and category ~= "main" then
            conf = conf[ category ]
        end

        if option == "color" or option == "queuedColor" then return unpack( conf.color ) end
        if option == "frameStrata" then return frameStratas[ conf.frameStrata ] or 3 end
        if option == "name" then return display end

        return conf[ option ]
    end

    local multiSet = false
    local timer

    local function QueueRebuildUI()
        if timer and not timer:IsCancelled() then timer:Cancel() end
        timer = C_Timer.NewTimer( 0.5, function ()
            Hekili:BuildUI()
        end )
    end

    function Hekili:SetDisplayOption( info, val, v2, v3, v4 )
        local n = #info
        local display, category, option = info[ 2 ], info[ 3 ], info[ n ]
        local set = false

        local all = false

        if category == "shareDisplays" then
            self:SetDisplayShareOption( info, val, v2, v3, v4 )
            return
        end

        local conf = self.DB.profile.displays[ display ]
        if category ~= option and category ~= 'main' then conf = conf[ category ] end

        if option == 'color' or option == 'queuedColor' then
            conf[ option ] = { val, v2, v3, v4 }
            set = true
        elseif option == 'frameStrata' then
            conf.frameStrata = frameStratas[ val ] or "LOW"
            set = true
        end

        if not set then
            val = type( val ) == 'string' and val:trim() or val
            conf[ option ] = val
        end

        if not multiSet then QueueRebuildUI() end
    end


    function Hekili:GetMultiDisplayOption( info )
        info[ 2 ] = "Primary"
        local val, v2, v3, v4 = self:GetDisplayOption( info )
        info[ 2 ] = "Multi"
        return val, v2, v3, v4
    end

    function Hekili:SetMultiDisplayOption( info, val, v2, v3, v4 )
        multiSet = true

        local orig = info[ 2 ]

        for display, active in pairs( multiDisplays ) do
            if active then
                info[ 2 ] = display
                self:SetDisplayOption( info, val, v2, v3, v4 )
            end
        end
        QueueRebuildUI()
        info[ 2 ] = orig

        multiSet = false
    end


    local function GetNotifOption( info )
        local n = #info
        local option = info[ n ]

        local conf = Hekili.DB.profile.notifications
        local val = conf[ option ]

        if option == "color" then
            if type( val ) == "table" and #val == 4 then
                return unpack( val )
            else
                local defaults = Hekili:GetDefaults()
                return unpack( defaults.profile.notifications.color )
            end
        end
        return val
    end

    local function SetNotifOption( info, ... )
        local n = #info
        local option = info[ n ]

        local conf = Hekili.DB.profile.notifications
        local val = option == "color" and { ... } or select(1, ...)

        conf[ option ] = val
        QueueRebuildUI()
    end

    local fontStyles = {
        ["MONOCHROME"] = "無消除鋸齒",
        ["MONOCHROME,OUTLINE"] = "無消除鋸齒、邊框",
        ["MONOCHROME,THICKOUTLINE"] = "無消除鋸齒、粗邊框",
        ["NONE"] = "無",
        ["OUTLINE"] = "邊框",
        ["THICKOUTLINE"] = "粗邊框"
    }

    local fontElements = {
        font = {
            type = "select",
            name = "字體",
            order = 1,
            width = 1.49,
            dialogControl = 'LSM30_Font',
            values = LSM:HashTable("font"),
        },

        fontStyle = {
            type = "select",
            name = "樣式",
            order = 2,
            values = fontStyles,
            width = 1.49
        },

        break01 = {
            type = "description",
            name = " ",
            order = 2.1,
            width = "full"
        },

        fontSize = {
            type = "range",
            name = "大小",
            order = 3,
            min = 8,
            max = 64,
            step = 1,
            width = 1.49
        },

        color = {
            type = "color",
            name = "顏色",
            order = 4,
            width = 1.49
        }
    }

    local anchorPositions = {
        TOP = '上',
        TOPLEFT = '左上',
        TOPRIGHT = '右上',
        BOTTOM = '下',
        BOTTOMLEFT = '左下',
        BOTTOMRIGHT = '右下',
        LEFT = '左',
        LEFTTOP = '上左',
        LEFTBOTTOM = '下左',
        RIGHT = '右',
        RIGHTTOP = '上右',
        RIGHTBOTTOM = '下右',
    }


    local realAnchorPositions = {
        TOP = '上',
        TOPLEFT = '左上',
        TOPRIGHT = '右上',
        BOTTOM = '下',
        BOTTOMLEFT = '左下',
        BOTTOMRIGHT = '右下',
        CENTER = "中",
        LEFT = '左',
        RIGHT = '右',
    }


    local function getOptionTable( info, notif )
        local disp = info[2]
        local tab = Hekili.Options.args.displays

        if notif then
            tab = tab.args.nPanel
        else
            tab = tab.plugins[ disp ][ disp ]
        end

        for i = 3, #info do
            tab = tab.args[ info[i] ]
        end

        return tab
    end

    local function rangeXY( info, notif )
        local tab = getOptionTable( info, notif )

        local resolution = GetCVar( "gxWindowedResolution" ) or "1280x720"
        local width, height = resolution:match( "(%d+)x(%d+)" )

        width = tonumber( width )
        height = tonumber( height )

        tab.args.x.min = -1 * width
        tab.args.x.max = width
        tab.args.x.softMin = -1 * width * 0.5
        tab.args.x.softMax = width * 0.5

        tab.args.y.min = -1 * height
        tab.args.y.max = height
        tab.args.y.softMin = -1 * height * 0.5
        tab.args.y.softMax = height * 0.5
    end


    local function setWidth( info, field, condition, if_true, if_false )
        local tab = getOptionTable( info )

        if condition then
            tab.args[ field ].width = if_true or "full"
        else
            tab.args[ field ].width = if_false or "full"
        end
    end


    local function rangeIcon( info )
        local tab = getOptionTable( info )

        local display = info[2]
        display = display == "Multi" and "Primary" or display

        local data = display and Hekili.DB.profile.displays[ display ]

        if data then
            tab.args.x.min = -1 * max( data.primaryWidth, data.queue.width )
            tab.args.x.max = max( data.primaryWidth, data.queue.width )

            tab.args.y.min = -1 * max( data.primaryHeight, data.queue.height )
            tab.args.y.max = max( data.primaryHeight, data.queue.height )

            return
        end

        tab.args.x.min = -50
        tab.args.x.max = 50

        tab.args.y.min = -50
        tab.args.y.max = 50
    end


    local dispCycle = { "Primary", "AOE", "Cooldowns", "Defensives", "Interrupts" }

    local MakeMultiDisplayOption
    local modified = {}

    local function GetOptionData( db, info )
        local display = info[ 2 ]
        local option = db[ display ][ display ]
        local desc, set, get = nil, option.set, option.get

        for i = 3, #info do
            local category = info[ i ]

            if not option then
                break

            elseif option.args then
                if not option.args[ category ] then
                    break
                end
                option = option.args[ category ]

            else
                break
            end

            get = option and option.get or get
            set = option and option.set or set
            desc = option and option.desc or desc
        end

        return option, get, set, desc
    end

    local function WrapSetter( db, data )
        local _, _, setfunc = GetOptionData( db, data )
        if setfunc and modified[ setfunc ] then return setfunc end

        local newFunc = function( info, val, v2, v3, v4 )
            multiSet = true

            for display, active in pairs( multiDisplays ) do
                if active then
                    info[ 2 ] = display

                    _, _, setfunc = GetOptionData( db, info )

                    if type( setfunc ) == "string" then
                        Hekili[ setfunc ]( Hekili, info, val, v2, v3, v4 )
                    elseif type( setfunc ) == "function" then
                        setfunc( info, val, v2, v3, v4 )
                    end
                end
            end

            multiSet = false

            info[ 2 ] = "Multi"
            QueueRebuildUI()
        end

        modified[ newFunc ] = true
        return newFunc
    end

    local function WrapDesc( db, data )
        local option, getfunc, _, descfunc = GetOptionData( db, data )
        if descfunc and modified[ descfunc ] then
            return descfunc
        end

        local newFunc = function( info )
            local output

            for _, display in ipairs( dispCycle ) do
                info[ 2 ] = display
                option, getfunc, _, descfunc = GetOptionData( db, info )

                if not output then
                    output = option and type( option.desc ) == "function" and ( option.desc( info ) or "" ) or ( option.desc or "" )
                    if output:len() > 0 then output = output .. "\n" end
                end

                local val, v2, v3, v4

                if not getfunc then
                    val, v2, v3, v4 = Hekili:GetDisplayOption( info )
                elseif type( getfunc ) == "function" then
                    val, v2, v3, v4 = getfunc( info )
                elseif type( getfunc ) == "string" then
                    val, v2, v3, v4 = Hekili[ getfunc ]( Hekili, info )
                end

                if val == nil then
                    Hekili:Error( "無法在 WrapDesc 中取得 %s 的值。", table.concat( info, ":" ) )
                    info[ 2 ] = "Multi"
                    return output
                end

                -- Sanitize/format values.
                if type( val ) == "boolean" then
                    val = val and "|cFF00FF00已勾選|r" or "|cFFFF0000未勾選|r"

                elseif option.type == "color" then
                    val = string.format( "|A:WhiteCircle-RaidBlips:16:16:0:0:%d:%d:%d|a |cFFFFD100#%02x%02x%02x|r", val * 255, v2 * 255, v3 * 255, val * 255, v2 * 255, v3 * 255 )

                elseif option.type == "select" and option.values and not option.dialogControl then
                    if type( option.values ) == "function" then
                        val = option.values( data )[ val ] or val
                    else
                        val = option.values[ val ] or val
                    end

                    if type( val ) == "number" then
                        if val % 1 == 0 then
                            val = format( "|cFFFFD100%d|r", val )
                        else
                            val = format( "|cFFFFD100%.2f|r", val )
                        end
                    else
                        val = format( "|cFFFFD100%s|r", tostring( val ) )
                    end

                elseif type( val ) == "number" then
                    if val % 1 == 0 then
                        val = format( "|cFFFFD100%d|r", val )
                    else
                        val = format( "|cFFFFD100%.2f|r", val )
                    end

                else
                    if val == nil then
                        Hekili:Error( "未找到 %s 的值，設為預設值 '???'。", table.concat( data, ":" ))
                        val = "|cFFFF0000???|r"
                    else
                        val = "|cFFFFD100" .. val .. "|r"
                    end
                end

                output = format( "%s%s%s%s:|r %s", output, output:len() > 0 and "\n" or "", BlizzBlue, display, val )
            end

            info[ 2 ] = "Multi"
            return output
        end

        modified[ newFunc ] = true
        return newFunc
    end

    local function GetDeepestSetter( db, info )
        local position = db.Multi.Multi
        local setter

        for i = 3, #info - 1 do
            local key = info[ i ]
            position = position.args[ key ]

            local setfunc = rawget( position, "set" )

            if setfunc and type( setfunc ) == "function" then
                setter = setfunc
            end
        end

        return setter
    end

    MakeMultiDisplayOption = function( db, t, inf )
        local info = {}

        if not inf or #inf == 0 then
            info[1] = "displays"
            info[2] = "Multi"

            for k, v in pairs( t ) do
                -- Only load groups in the first level (bypasses selection for which display to edit).
                if v.type == "group" then
                    info[3] = k
                    MakeMultiDisplayOption( db, v.args, info )
                    info[3] = nil
                end
            end

            return

        else
            for i, v in ipairs( inf ) do
                info[ i ] = v
            end
        end

        for k, v in pairs( t ) do
            if k:match( "^MultiMod" ) then
                -- do nothing.
            elseif v.type == "group" then
                info[ #info + 1 ] = k
                MakeMultiDisplayOption( db, v.args, info )
                info[ #info ] = nil
            elseif inf and v.type ~= "description" then
                info[ #info + 1 ] = k
                v.desc = WrapDesc( db, info )

                if rawget( v, "set" ) then
                    v.set = WrapSetter( db, info )
                else
                    local setfunc = GetDeepestSetter( db, info )
                    if setfunc then v.set = WrapSetter( db, info ) end
                end

                info[ #info ] = nil
            end
        end
    end


    local function newDisplayOption( db, name, data, pos )
        name = tostring( name )

        local fancyName

        if name == "Multi" then fancyName = AtlasToString( "auctionhouse-icon-favorite" ) .. " 多個"
        elseif name == "Defensives" then fancyName = AtlasToString( "nameplates-InterruptShield" ) .. " 防禦 Defensives"
        elseif name == "Interrupts" then fancyName = AtlasToString( "voicechat-icon-speaker-mute" ) .. " 斷法 Interrupts"
        elseif name == "Cooldowns" then fancyName = AtlasToString( "chromietime-32x32" ) .. " 冷卻 Cooldowns"
        elseif name == "Primary" then fancyName = "主要 Primary"
        elseif name == "AOE" then fancyName = "多目標 AOE"
        else fancyName = name end

        local option = {
            ['btn'..name] = {
                type = 'execute',
                name = fancyName,
                desc = data.desc,
                order = 10 + pos,
                func = function () ACD:SelectGroup( "Hekili", "displays", name ) end,
            },

            [name] = {
                type = 'group',
                name = function ()
                    if name == "Multi" then return "|cFF00FF00" .. fancyName .. "|r"
                    elseif data.builtIn then return '|cFF00B4FF' .. fancyName .. '|r' end
                    return fancyName
                end,
                desc = function ()
                    if name == "Multi" then
                        return "允許同時編輯多種技能組。技能組的設定來自主要技能組 (其他技能組的設定顯示在浮動提示資訊中)。\n\n編輯多種技能組時，某些選項會被停用。"
                    end
                    return data.desc
                end,
                set = name == "Multi" and "SetMultiDisplayOption" or "SetDisplayOption",
                get = name == "Multi" and "GetMultiDisplayOption" or "GetDisplayOption",
                childGroups = "tab",
                order = 100 + pos,

                args = {
                    MultiModPrimary = {
                        type = "toggle",
                        name = function() return multiDisplays.Primary and "|cFF00FF00主要|r" or "|cFFFF0000主要|r" end,
                        desc = function()
                            if multiDisplays.Primary then return "更改將|cFF00FF00會|r套用到主要技能組。" end
                            return "更改將|cFFFF0000不會|r套用到主要技能組。"
                        end,
                        order = 0.01,
                        width = 0.65,
                        get = function() return multiDisplays.Primary end,
                        set = function() multiDisplays.Primary = not multiDisplays.Primary end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModAOE = {
                        type = "toggle",
                        name = function() return multiDisplays.AOE and "|cFF00FF00多目標|r" or "|cFFFF0000多目標|r" end,
                        desc = function()
                            if multiDisplays.AOE then return "更改將|cFF00FF00會|r套用到多目標技能組。" end
                            return "更改將|cFFFF0000不會|r套用到多目標技能組。"
                        end,
                        order = 0.02,
                        width = 0.65,
                        get = function() return multiDisplays.AOE end,
                        set = function() multiDisplays.AOE = not multiDisplays.AOE end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModCooldowns = {
                        type = "toggle",
                        name = function () return AtlasToString( "chromietime-32x32" ) .. ( multiDisplays.Cooldowns and " |cFF00FF00冷卻|r" or " |cFFFF0000冷卻|r" ) end,
                        desc = function()
                            if multiDisplays.Cooldowns then return "更改將|cFF00FF00會|r套用到冷卻技能組。" end
                            return "更改將|cFFFF0000不會|r套用到冷卻技能組。"
                        end,
                        order = 0.03,
                        width = 0.65,
                        get = function() return multiDisplays.Cooldowns end,
                        set = function() multiDisplays.Cooldowns = not multiDisplays.Cooldowns end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModDefensives = {
                        type = "toggle",
                        name = function () return AtlasToString( "nameplates-InterruptShield" ) .. ( multiDisplays.Defensives and " |cFF00FF00防禦|r" or " |cFFFF0000防禦|r" ) end,
                        desc = function()
                            if multiDisplays.Defensives then return "更改將|cFF00FF00會|r套用到防禦技能組。" end
                            return "更改將|cFFFF0000不會|r套用到防禦技能組。"
                        end,
                        order = 0.04,
                        width = 0.65,
                        get = function() return multiDisplays.Defensives end,
                        set = function() multiDisplays.Defensives = not multiDisplays.Defensives end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModInterrupts = {
                        type = "toggle",
                        name = function () return AtlasToString( "voicechat-icon-speaker-mute" ) .. ( multiDisplays.Interrupts and " |cFF00FF00斷法|r" or " |cFFFF0000斷法|r" ) end,
                        desc = function()
                            if multiDisplays.Interrupts then return "更改將|cFF00FF00會|r套用到斷法技能組。" end
                            return "更改將|cFFFF0000不會|r套用到斷法技能組。"
                        end,
                        order = 0.05,
                        width = 0.65,
                        get = function() return multiDisplays.Interrupts end,
                        set = function() multiDisplays.Interrupts = not multiDisplays.Interrupts end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    main = {
						type = 'group',
						name = "圖示",
						desc = "包含技能組的位置、圖示大小/形狀...等等。",
						order = 1,

						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "如果停用，此技能組在任何情況下都不會出現。",
								order = 0.5,
								hidden = function () return data.name == "Primary" or data.name == "AOE" or data.name == "Cooldowns"  or data.name == "Defensives" or data.name == "Interrupts" end
							},

							elvuiCooldown = {
								type = "toggle",
								name = "將 ElvUI 冷卻時間樣式套用於主要圖示",
								desc = "如果安裝了 ElvUI，您可以將 ElvUI 冷卻時間樣式套用於排隊的圖示。\n\n停用此設定需要重新載入介面 (|cFFFFD100/reload|r)。",
								width = "full",
								order = 16,
								hidden = function () return _G["ElvUI"] == nil end,
							},

							numIcons = {
								type = 'range',
								name = "要顯示幾個圖示",
								desc = "指定要顯示的建議技能數量，每個圖示都代表著接下來要施放的技能。",
								min = 1,
								max = 10,
								step = 1,
								bigStep = 1,
								width = "full",
								order = 1,
								disabled = function()
									return name == "Multi"
								end,
								hidden = function( info, val )
									local n = #info
									local display = info[2]

									if display == "Defensives" or display == "Interrupts" then
										return true
									end

									return false
								end,
							},

							forecastPeriod = {
								type = "range",
								name = "預測週期",
								desc = "指定插件用來產生建議的參考時間。 例如，在冷卻技能組中，如果設為 |cFFFFD10015|r (預設)，則"
									.. "冷卻中的技能可以在冷卻時間剩下 15 秒且滿足使用條件時開始出現。\n\n"
									.. "如果設定為非常短的週期，則可能會因為沒有滿足資源需求和使用條件，且冷卻時間未結束的技能而無法產生建議。",
								softMin = 1.5,
								min = 0,
								softMax = 15,
								max = 30,
								step = 0.1,
								width = "full",
								order = 2,
								disabled = function()
									return name == "Multi"
								end,
								hidden = function( info, val )
									local n = #info
									local display = info[2]

									if display == "Primary" or display == "AOE" then
										return true
									end

									return false
								end,
							},

							pos = {
								type = "group",
								inline = true,
								name = function( info ) rangeXY( info ); return "位置" end,
								order = 10,

								args = {
									--[[
									relativeTo = {
										type = "select",
										name = "對齊到",
										values = {
											SCREEN = "畫面",
											PERSONAL = "個人資源條",
											CUSTOM = "自訂"
										},
										order = 1,
										width = 1.49,
									},

									customFrame = {
										type = "input",
										name = "自訂框架",
										desc = "指定此技能組將定位的框架名稱。\n" ..
												"如果框架不存在，則不會顯示。",
										order = 1.1,
										width = 1.49,
										hidden = function() return data.relativeTo ~= "CUSTOM" end,
									},

									setParent = {
										type = "toggle",
										name = "對齊到父框架",
										desc = "勾選時，則技能組將跟著父框架一起顯示/隱藏。",
										order = 3.9,
										width = 1.49,
										hidden = function() return data.relativeTo == "SCREEN" end,
									},

									preXY = {
										type = "description",
										name = " ",
										width = "full",
										order = 97
									}, ]]

									x = {
										type = "range",
										name = "水平位置",
										desc = "設定此技能組的主要圖示，相對於畫面中心的水平位置。 負數" ..
											"值會將技能組向左移動；正數會向右移動。",
										min = -512,
										max = 512,
										step = 1,

										order = 98,
										width = 1.49,

										disabled = function()
											return name == "Multi"
										end,
									},

									y = {
										type = "range",
										name = "垂直位置",
										desc = "設定此技能組的主要圖示，相對於畫面中心的垂直位置。 負數" ..
											"值會將技能組向下移動；正數會向上移動。",
										min = -384,
										max = 384,
										step = 1,

										order = 99,
										width = 1.49,

										disabled = function()
											return name == "Multi"
										end,
									},
								},
							},

							primaryIcon = {
								type = "group",
								name = "主要圖示",
								inline = true,
								order = 15,
								args = {
									primaryWidth = {
										type = "range",
										name = "寬度",
										desc = "指定" .. ( name == "Multi" and "每個技能組" or ( "你的 " .. name .. " 技能組" ) ) .. "的主要圖示寬度。",
										min = 10,
										max = 500,
										step = 1,

										width = 1.49,
										order = 1,
									},

									primaryHeight = {
										type = "range",
										name = "高度",
										desc = "指定" .. ( name == "Multi" and "每個技能組" or ( "你的 " .. name .. " 技能組" ) ) .. "的主要圖示高度。",
										min = 10,
										max = 500,
										step = 1,

										width = 1.49,
										order = 2,
									},

									spacer01 = {
										type = "description",
										name = " ",
										width = "full",
										order = 3
									},

									zoom = {
										type = "range",
										name = "圖示大小",
										desc = "選擇此技能組中圖示的縮放百分比。 (大約 30% 將修剪掉預設的邊框。)",
										min = 0,
										softMax = 100,
										max = 200,
										step = 1,

										width = 1.49,
										order = 4,
									},

									keepAspectRatio = {
										type = "toggle",
										name = "保持比例",
										desc = "如果主要或排隊圖示不是正方形，勾選此選項將防止圖示被" ..
											"拉長或扭曲，而是修剪掉一些圖案。",
										disabled = function( info, val )
											return not ( data.primaryHeight ~= data.primaryWidth or ( data.numIcons > 1 and data.queue.height ~= data.queue.width ) )
										end,
										width = 1.49,
										order = 5,
									},
								},
							},

							advancedFrame = {
								type = "group",
								name = "技能組框架層級",
								inline = true,
								order = 99,
								args = {
									frameStrata = {
										type = "select",
										name = "層級",
										desc =  "框架層級決定此技能組繪製在哪個圖層。\n\n" ..
												"預設層級為 |cFFFFD100MEDIUM|r。",
										values = {
											"BACKGROUND",
											"LOW",
											"MEDIUM",
											"HIGH",
											"DIALOG",
											"FULLSCREEN",
											"FULLSCREEN_DIALOG",
											"TOOLTIP"
										},
										width = "full",
										order = 1,
									},
								},
							},

							queuedElvuiCooldown = {
								type = "toggle",
								name = "將 ElvUI 冷卻時間樣式套用於排隊圖示",
								desc = "如果安裝了 ElvUI，可以將 ElvUI 冷卻時間樣式套用於排隊中的圖示。\n\n停用此設定需要重新載入介面 (|cFFFFD100/reload|r)。",
								width = "full",
								order = 23,
								get = function( info )
									return Hekili.DB.profile.displays[ name ].queue.elvuiCooldown
								end,
								set = function( info, val )
									Hekili.DB.profile.displays[ name ].queue.elvuiCooldown = val
								end,
								hidden = function () return _G["ElvUI"] == nil end,
							},

							iconSizeGroup = {
								type = "group",
								inline = true,
								name = "排隊圖示大小",
								order = 21,
								args = {
									width = {
										type = 'range',
										name = '寬度',
										desc = "選擇排隊圖示的寬度。",
										min = 10,
										max = 500,
										step = 1,
										bigStep = 1,
										order = 10,
										width = 1.49,
										get = function( info )
											return Hekili.DB.profile.displays[ name ].queue.width
										end,
										set = function( info, val )
											Hekili.DB.profile.displays[ name ].queue.width = val
										end,
									},

									height = {
										type = 'range',
										name = '高度',
										desc = "選擇排隊圖示的高度。",
										min = 10,
										max = 500,
										step = 1,
										bigStep = 1,
										order = 11,
										width = 1.49,
										get = function( info )
											return Hekili.DB.profile.displays[ name ].queue.height
										end,
										set = function( info, val )
											Hekili.DB.profile.displays[ name ].queue.height = val
										end,
									},
								}
							},

							anchorGroup = {
								type = "group",
								inline = true,
								name = "排隊圖示位置",
								order = 22,
								args = {
									anchor = {
										type = 'select',
										name = '對齊到',
										desc = "選擇排隊圖示要附加到的主要圖示上的哪個點。",
										values = anchorPositions,
										width = 1.49,
										order = 1,
										get = function( info )
											return Hekili.DB.profile.displays[ name ].queue.anchor
										end,
										set = function( info, val )
											Hekili.DB.profile.displays[ name ].queue.anchor = val
											Hekili:BuildUI()
										end,
									},

									direction = {
										type = 'select',
										name = '增長方向',
										desc = "選擇圖示增長的方向。\n\n"
											.. "此選項通常與 '對齊到' 的選擇有關，但你可以指定另一個方向來建立有創意的版面配置。",
										values = {
											TOP = '上',
											BOTTOM = '下',
											LEFT = '左',
											RIGHT = '右'
										},
										width = 1.49,
										order = 1.1,
										get = function( info )
											return Hekili.DB.profile.displays[ name ].queue.direction
										end,
										set = function( info, val )
											Hekili.DB.profile.displays[ name ].queue.direction = val
											Hekili:BuildUI()
										end,
									},

									spacer01 = {
										type = "description",
										name = " ",
										order = 1.2,
										width = "full",
									},

									offsetX = {
										type = 'range',
										name = '水平位移',
										desc = "指定排隊圖示的水平位置偏移量 (以像素為單位)，相對於此技能組主要圖示上的定位點。\n\n"
											.. "正數會將排隊圖示向右移動，負數會向左移動。",
										min = -100,
										max = 500,
										step = 1,
										width = 1.49,
										order = 2,
										get = function( info )
											return Hekili.DB.profile.displays[ name ].queue.offsetX
										end,
										set = function( info, val )
											Hekili.DB.profile.displays[ name ].queue.offsetX = val
											Hekili:BuildUI()
										end,
									},

									offsetY = {
										type = 'range',
										name = '垂直位移',
										desc = "指定排隊圖示的垂直位置偏移量 (以像素為單位)，相對於此技能組主要圖示上的定位點。\n\n"
											.. "正數會將排隊圖示向右移動，負數會向左移動。",
										min = -100,
										max = 500,
										step = 1,
										width = 1.49,
										order = 2.1,
										get = function( info )
											return Hekili.DB.profile.displays[ name ].queue.offsetY
										end,
										set = function( info, val )
											Hekili.DB.profile.displays[ name ].queue.offsetY = val
											Hekili:BuildUI()
										end,
									},

									spacer02 = {
										type = "description",
										name = " ",
										order = 2.2,
										width = "full",
									},

									spacing = {
										type = 'range',
										name = '圖示間距',
										desc = "選擇排隊圖示之間要距離幾個像素。",
										softMin = ( data.queue.direction == "LEFT" or data.queue.direction == "RIGHT" ) and -data.queue.width or -data.queue.height,
										softMax = ( data.queue.direction == "LEFT" or data.queue.direction == "RIGHT" ) and data.queue.width or data.queue.height,
										min = -500,
										max = 500,
										step = 1,
										order = 3,
										width = 2.98,
										get = function( info )
											return Hekili.DB.profile.displays[ name ].queue.spacing
										end,
										set = function( info, val )
											Hekili.DB.profile.displays[ name ].queue.spacing = val
											Hekili:BuildUI()
										end,
									},
								}
							},
						},
					},

                    visibility = {
						type = 'group',
						name = '顯示',
						desc = "在 PvE / PvP 中的技能組的顯示和透明度設定。",
						order = 3,

						args = {

							advanced = {
								type = "toggle",
								name = "進階",
								desc = "勾選時，將提供顯示和透明度的微調選項。",
								width = "full",
								order = 1,
							},

							simple = {
								type = 'group',
								inline = true,
								name = "",
								hidden = function() return data.visibility.advanced end,
								get = function( info )
									local option = info[ #info ]

									if option == 'pveAlpha' then return data.visibility.pve.alpha
									elseif option == 'pvpAlpha' then return data.visibility.pvp.alpha end
								end,
								set = function( info, val )
									local option = info[ #info ]

									if option == 'pveAlpha' then data.visibility.pve.alpha = val
									elseif option == 'pvpAlpha' then data.visibility.pvp.alpha = val end

									QueueRebuildUI()
								end,
								order = 2,
								args = {
									pveAlpha = {
										type = "range",
										name = "PvE 透明度",
										desc = "設定在 PvE 環境中的技能組透明度。設為 0 時不會出現在 PvE 中。",
										min = 0,
										max = 1,
										step = 0.01,
										order = 1,
										width = 1.49,
									},
									pvpAlpha = {
										type = "range",
										name = "PvP 透明度",
										desc = "設定在 PvP 環境中的技能組透明度。設為 0 時不會出現在 PvP 中。",
										min = 0,
										max = 1,
										step = 0.01,
										order = 1,
										width = 1.49,
									},
								}
							},

							pveComplex = {
								type = 'group',
								inline = true,
								name = "PvE",
								get = function( info )
									local option = info[ #info ]

									return data.visibility.pve[ option ]
								end,
								set = function( info, val )
									local option = info[ #info ]

									data.visibility.pve[ option ] = val
									QueueRebuildUI()
								end,
								hidden = function() return not data.visibility.advanced end,
								order = 2,
								args = {
									always = {
										type = "range",
										name = "預設",
										desc = "不是 0 時，預設會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 1,
									},

									combat = {
										type = "range",
										name = "戰鬥",
										desc = "不是 0 時，在 PvE 戰鬥中會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 3,
									},

									break01 = {
										type = "description",
										name = " ",
										width = "full",
										order = 2.1
									},

									target = {
										type = "range",
										name = "目標",
										desc = "不是 0 時，在有可攻擊的 PvE 目標時會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 2,
									},

									combatTarget = {
										type = "range",
										name = "戰鬥中目標",
										desc = "不是 0 時，處於戰鬥狀態且有可攻擊的 PvE 目標時會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 4,
									},

									hideMounted = {
										type = "toggle",
										name = "騎乘時隱藏",
										desc = "勾選時，騎乘坐騎且不在戰鬥狀態時，將不會顯示技能組。",
										width = "full",
										order = 0.5,
									}
								},
							},

							pvpComplex = {
								type = 'group',
								inline = true,
								name = "PvP",
								get = function( info )
									local option = info[ #info ]

									return data.visibility.pvp[ option ]
								end,
								set = function( info, val )
									local option = info[ #info ]

									data.visibility.pvp[ option ] = val
									QueueRebuildUI()
									Hekili:UpdateDisplayVisibility()
								end,
								hidden = function() return not data.visibility.advanced end,
								order = 2,
								args = {
									always = {
										type = "range",
										name = "預設",
										desc = "不是 0 時，預設會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 1,
									},

									combat = {
										type = "range",
										name = "戰鬥",
										desc = "不是 0 時，在 PvP 戰鬥中會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 3,
									},

									break01 = {
										type = "description",
										name = " ",
										width = "full",
										order = 2.1
									},

									target = {
										type = "range",
										name = "目標",
										desc = "不是 0 時，在有可攻擊的 PvP 目標時會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 2,
									},

									combatTarget = {
										type = "range",
										name = "戰鬥中目標",
										desc = "不是 0 時，處於戰鬥狀態且有可攻擊的 PvP 目標時會以指定的透明度來顯示技能組。",
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
										order = 4,
									},

									hideMounted = {
										type = "toggle",
										name = "騎乘時隱藏",
										desc = "勾選時，騎乘坐騎將不會顯示技能組，除非你在戰鬥狀態。",
										width = "full",
										order = 0.5,
									}
								},
							},
						},
					},

                    keybindings = {
						type = "group",
						name = "按鍵綁定",
						desc = "顯示圖示上按鍵綁定文字的選項。",
						order = 7,

						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								order = 1,
								width = 1.49,
							},

							queued = {
								type = "toggle",
								name = "排隊圖示啟用",
								order = 2,
								width = 1.49,
								disabled = function () return data.keybindings.enabled == false end,
							},

							pos = {
								type = "group",
								inline = true,
								name = function( info ) rangeIcon( info ); return "位置" end,
								order = 3,
								args = {
									anchor = {
										type = "select",
										name = '位置',
										order = 2,
										width = 1,
										values = realAnchorPositions
									},

									x = {
										type = "range",
										name = "水平位移",
										order = 3,
										width = 0.99,
										min = -max( data.primaryWidth, data.queue.width ),
										max = max( data.primaryWidth, data.queue.width ),
										disabled = function( info )
											return false
										end,
										step = 1,
									},

									y = {
										type = "range",
										name = "垂直位移",
										order = 4,
										width = 0.99,
										min = -max( data.primaryHeight, data.queue.height ),
										max = max( data.primaryHeight, data.queue.height ),
										step = 1,
									}
								}
							},

							textStyle = {
								type = "group",
								inline = true,
								name = "字體和樣式",
								order = 5,
								args = tableCopy( fontElements ),
							},

							lowercase = {
								type = "toggle",
								name = "使用小寫",
								order = 5.1,
								width = "full",
							},

							separateQueueStyle = {
								type = "toggle",
								name = "排隊圖示使用不同設定",
								order = 6,
								width = "full",
							},

							queuedTextStyle = {
								type = "group",
								inline = true,
								name = "排隊圖示字體和樣式",
								order = 7,
								hidden = function () return not data.keybindings.separateQueueStyle end,
								args = {
									queuedFont = {
										type = "select",
										name = "字體",
										order = 1,
										width = 1.49,
										dialogControl = 'LSM30_Font',
										values = LSM:HashTable("font"),
									},

									queuedFontStyle = {
										type = "select",
										name = "樣式",
										order = 2,
										values = fontStyles,
										width = 1.49
									},

									break01 = {
										type = "description",
										name = " ",
										width = "full",
										order = 2.1
									},

									queuedFontSize = {
										type = "range",
										name = "大小",
										order = 3,
										min = 8,
										max = 64,
										step = 1,
										width = 1.49
									},

									queuedColor = {
										type = "color",
										name = "顏色",
										order = 4,
										width = 1.49
									}
								},
							},

							queuedLowercase = {
								type = "toggle",
								name = "排隊圖示使用小寫",
								order = 7.1,
								width = 1.49,
								hidden = function () return not data.keybindings.separateQueueStyle end,
							},

							cPort = {
								name = "ConsolePort",
								type = "group",
								inline = true,
								order = 4,
								args = {
									cPortOverride = {
										type = "toggle",
										name = "使用 ConsolePort 按鈕",
										order = 6,
										width = 1.49,
									},

									cPortZoom = {
										type = "range",
										name = "ConsolePort 按鈕縮放",
										desc = "ConsolePort 按鈕通常在周圍有大量的空白空隙。" ..
											"縮放會移除一些空隙以幫助按鈕適合圖示。預設為 |cFFFFD1000.6|r。",
										order = 7,
										min = 0,
										max = 1,
										step = 0.01,
										width = 1.49,
									},
								},
								disabled = function() return ConsolePort == nil end,
							},

						}
					},

					border = {
						type = "group",
						name = "邊框",
						desc = "啟用/停用或設定圖示邊框的顏色。\n\n" ..
							"如果你使用 Masque 或其他插件來美化 Hekili 輸出助手圖示，可能需要停用此功能。",
						order = 4,

						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "啟用時，此技能組中的每個圖示都將有細邊框。",
								order = 1,
								width = "full",
							},

							thickness = {
								type = "range",
								name = "邊框粗細",
								desc = "決定邊框的粗細 (寬度)，預設為 1。",
								softMin = 1,
								softMax = 20,
								step = 1,
								order = 2,
								width = 1.49,
							},

							fit = {
								type = "toggle",
								name = "邊框在內部",
								desc = "啟用時，邊框將會位於內部 (而不是周圍)。",
								order = 2.5,
								width = 1.49
							},

							break01 = {
								type = "description",
								name = " ",
								width = "full",
								order = 2.6
							},

							coloring = {
								type = "select",
								name = "顏色模式",
								desc = "指定要使用職業顏色還是自訂顏色邊框。\n\n職業顏色邊框將會自動更改以符合你正在玩的職業。",
								width = 1.49,
								order = 3,
								values = {
									class = format( "職業 |A:WhiteCircle-RaidBlips:16:16:0:0:%d:%d:%d|a #%s", ClassColor.r * 255, ClassColor.g * 255, ClassColor.b * 255, ClassColor:GenerateHexColor():sub( 3, 8 ) ),
									custom = "自訂顏色"
								},
								disabled = function() return data.border.enabled == false end,
							},

							color = {
								type = "color",
								name = "自訂顏色",
								desc = "當邊框啟用且顏色模式設定為|cFFFFD100自訂顏色|r時，邊框將會使用此顏色。",
								order = 4,
								width = 1.49,
								disabled = function () return data.border.enabled == false or data.border.coloring ~= "custom" end,
							}
						}
					},

					range = {
						type = "group",
						name = "範圍",
						desc = "如果需要，範圍檢查警告的偏好設定。",
						order = 5,
						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "啟用時，當你不在敵人範圍內時，插件將會提供紅色警告的顯著標示。",
								width = 1.49,
								order = 1,
							},

							type = {
								type = "select",
								name = '範圍檢查',
								desc = "選擇此技能組要使用的範圍檢查和範圍顏色類型。\n\n" ..
									"|cFFFFD100技能|r - 如果技能超出範圍，則該技能會以紅色顯著標示。\n\n" ..
									"|cFFFFD100近戰|r - 如果你超出近戰範圍，則所有技能都會以紅色顯著標示。\n\n" ..
									"|cFFFFD100排除|r - 如果技能不在範圍內，則不會推薦你使用該技能。",
								values = {
									ability = "每個技能",
									melee = "近戰範圍",
									xclude = "排除超出範圍的技能"
								},
								width = 1.49,
								order = 2,
								disabled = function () return data.range.enabled == false end,
							}
						}
					},

                    glow = {
						type = "group",
						name = "發光",
						desc = "暴雪快捷列按鈕發光的偏好設定（不是 SpellFlash）。",
						order = 6,
						args = {
							enabled = {
								type = "toggle",
								name = "啟用發光",
								desc = "啟用時，當第一個圖示的技能觸發 (或發光) 時，也會在此技能組中發光。",
								width = 1.49,
								order = 1,
							},

							queued = {
								type = "toggle",
								name = "排隊圖示啟用",
								desc = "啟用時，觸發 (或發光) 的技能也會在排隊圖示中發光。\n\n" ..
									"這可能不理想，輪到這個技能時可能不一定還在發光。",
								width = 1.49,
								order = 2,
								disabled = function() return data.glow.enabled == false end,
							},

							break01 = {
								type = "description",
								name = " ",
								order = 2.1,
								width = "full"
							},

							mode = {
								type = "select",
								name = "發光樣式",
								desc = "為技能組選擇發光樣式。",
								width = 1,
								order = 3,
								values = {
									default = "預設按鈕發光",
									autocast = "自動施法的亮光",
									pixel = "像素發光",
								},
								disabled = function() return data.glow.enabled == false end,
							},

							coloring = {
								type = "select",
								name = "顏色模式",
								desc = "為此發光效果選擇顏色模式。\n\n職業顏色邊框將會自動更改以符合你正在玩的職業。",
								width = 0.99,
								order = 4,
								values = {
									default = "使用預設顏色",
									class = format( "職業 |A:WhiteCircle-RaidBlips:16:16:0:0:%d:%d:%d|a #%s", ClassColor.r * 255, ClassColor.g * 255, ClassColor.b * 255, ClassColor:GenerateHexColor():sub( 3, 8 ) ),
									custom = "自訂顏色"
								},
								disabled = function() return data.glow.enabled == false end,
							},

							color = {
								type = "color",
								name = "發光顏色",
								desc = "為技能組選擇自訂發光顏色。",
								width = 0.99,
								order = 5,
								disabled = function() return data.glow.coloring ~= "custom" end,
							},

							break02 = {
								type = "description",
								name = " ",
								order = 10,
								width = "full",
							},

							highlight = {
								type = "toggle",
								name = "啟用動作顯著標示",
								desc = "啟用時，當最建議使用的物品/技能目前仍在排隊時，插件會套用預設的顯著標示。",
								width = "full",
								order = 11
							},
						},
					},

					flash = {
						type = "group",
						name = "SpellFlash",
						desc = function ()
							if SF then
								return "啟用時，插件可以在快捷列上顯著標示出推薦使用的技能。"
							end
							return "此功能需要 SpellFlashCore 插件或函式庫才能運作。"
						end,
						order = 8,
						args = {
							warning = {
								type = "description",
								name = "無法使用這些設定，因為未安裝或已停用 SpellFlashCore 插件/函式庫。",
								order = 0,
								fontSize = "medium",
								width = "full",
								hidden = function () return SF ~= nil end,
							},

							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "啟用時，插件將會在這個技能組最推薦使用的技能上顯示彩色的發光。",

								width = 1.49,
								order = 1,
								hidden = function () return SF == nil end,
							},

							color = {
								type = "color",
								name = "顏色",
								desc = "為 SpellFlash 顯著標示指定發光顏色。",
								order = 2,
								width = 1.49,
								hidden = function () return SF == nil end,
							},

							break00 = {
								type = "description",
								name = " ",
								order = 2.1,
								width = "full",
								hidden = function () return SF == nil end,
							},

							sample = {
								type = "description",
								name = "",
								image = function() return Hekili.DB.profile.flashTexture end,
								order = 3,
								width = 0.3,
								hidden = function () return SF == nil end,
							},

							flashTexture = {
								type = "select",
								name = "材質",
								icon =  function() return data.flash.texture or "Interface\\Cooldown\\star4" end,
								desc = "你選擇的材質將會覆蓋所有技能組的 SpellFlash 閃光效果 。",
								order = 3.1,
								width = 1.19,
								values = {
									["Interface\\AddOns\\Hekili\\Textures\\MonoCircle2"] = "單色圓形 (細)",
									["Interface\\AddOns\\Hekili\\Textures\\MonoCircle5"] = "單色圓形 (粗)",
									["Interface\\Cooldown\\ping4"] = "圓形",
									["Interface\\Cooldown\\star4"] = "星星 (預設)",
									["Interface\\Cooldown\\starburst"] = "星爆",
									["Interface\\Masks\\CircleMaskScalable"] = "實心圓形",
									["Interface\\Masks\\SquareMask"] = "實心正方形",
									["Interface\\Soulbinds\\SoulbindsConduitCollectionsIconMask"] = "實心八邊形",
									["Interface\\Soulbinds\\SoulbindsConduitPendingAnimationMask"] = "八邊形外框",
									["Interface\\Soulbinds\\SoulbindsEnhancedConduitMask"] = "八邊形 (粗)",
								},
								get = function()
									return Hekili.DB.profile.flashTexture
								end,
								set = function( _, val )
									Hekili.DB.profile.flashTexture = val
								end,
								hidden = function () return SF == nil end,
							},

							speed = {
								type = "range",
								name = "速度",
								desc = "指定閃光效果的刷新頻率，預設為 |cFFFFD1000.4秒|r。",
								min = 0.1,
								max = 2,
								step = 0.1,
								order = 3.2,
								width = 1.49,
								hidden = function () return SF == nil end,
							},

							break01 = {
								type = "description",
								name = " ",
								order = 4,
								width = "full",
								hidden = function () return SF == nil end,
							},

							size = {
								type = "range",
								name = "閃光大小",
								desc = "指定 SpellFlash 發光的尺寸，預設為 |cFFFFD100240|r。",
								order = 5,
								min = 0,
								max = 240 * 8,
								step = 1,
								width = 1.49,
								hidden = function () return SF == nil end,
							},

							fixedSize = {
								type = "toggle",
								name = "固定尺寸",
								desc = "勾選時，將會抑制 SpellFlash 脈衝 (放大和縮小) 動畫。",
								order = 6,
								width = 1.49,
								hidden = function () return SF == nil end,
							},

							break02 = {
								type = "description",
								name = " ",
								order = 7,
								width = "full",
								hidden = function () return SF == nil end,
							},

							brightness = {
								type = "range",
								name = "閃光亮度",
								desc = "指定 SpellFlash 發光的亮度，預設為 |cFFFFD100100|r。",
								order = 8,
								min = 0,
								max = 100,
								step = 1,
								width = 1.49,
								hidden = function () return SF == nil end,
							},

							fixedBrightness = {
								type = "toggle",
								name = "固定亮度",
								desc = "勾選時，SpellFlash 發光將不會變暗/變亮。",
								order = 9,
								width = 1.49,
								hidden = function () return SF == nil end,
							},

							break03 = {
								type = "description",
								name = " ",
								order = 10,
								width = "full",
								hidden = function () return SF == nil end,
							},

							combat = {
								type = "toggle",
								name = "只有戰鬥中",
								desc = "勾選時，插件只會在你處於戰鬥狀態時建立閃光。",
								order = 11,
								width = "full",
								hidden = function () return SF == nil end,
							},

							suppress = {
								type = "toggle",
								name = "隱藏技能組",
								desc = "勾選時，插件將不會顯示此技能組，只會通過 SpellFlash 提供建議。",
								order = 12,
								width = "full",
								hidden = function () return SF == nil end,
							},

							blink = {
								type = "toggle",
								name = "按鈕閃爍",
								desc = "啟用時，整個動作按鈕都會淡入淡出，預設為 |cFFFF0000停用|r。",
								order = 13,
								width = "full",
								hidden = function () return SF == nil end,
							},
						},
					},

                    captions = {
						type = "group",
						name = "說明文字",
						desc = "說明文字是動作列表中偶爾 (很少) 會使用的簡短描述，用於描述顯示此動作的原因。",
						order = 9,
						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "啟用時，當顯示的第一個技能有說明文字時，將會顯示說明文字。",
								order = 1,
								width = 1.49,
							},

							queued = {
								type = "toggle",
								name = "排隊圖示啟用",
								desc = "啟用時，如果適合，將會顯示排隊技能的說明文字。",
								order = 2,
								width = 1.49,
								disabled = function () return data.captions.enabled == false end,
							},

							position = {
								type = "group",
								inline = true,
								name = function( info ) rangeIcon( info ); return "位置" end,
								order = 3,
								args = {
									anchor = {
										type = "select",
										name = '位置',
										order = 1,
										width = 1,
										values = {
											TOP = '上',
											BOTTOM = '下',
										}
									},

									x = {
										type = "range",
										name = "水平位移",
										order = 2,
										width = 0.99,
										step = 1,
									},

									y = {
										type = "range",
										name = "垂直位移",
										order = 3,
										width = 0.99,
										step = 1,
									},

									break01 = {
										type = "description",
										name = " ",
										order = 3.1,
										width = "full",
									},

									align = {
										type = "select",
										name = "對齊方式",
										order = 4,
										width = 1.49,
										values = {
											LEFT = "靠左",
											RIGHT = "靠右",
											CENTER = "居中"
										},
									},
								}
							},

							textStyle = {
								type = "group",
								inline = true,
								name = "文字",
								order = 4,
								args = tableCopy( fontElements ),
							},
						}
					},

                    empowerment = {
						type = "group",
						name =  "強化",
						desc = "強化階段會在推薦圖示上顯示額外文字，並且在達到所需的階段時發光。",
						order = 9.1,
						hidden = function()
							return class.file ~= "EVOKER"
						end,
						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "啟用時，當顯示的第一個技能是強化法術時，將會顯示法術的強化階段。",
								order = 1,
								width = 1.49,
							},

							queued = {
								type = "toggle",
								name = "排隊圖示啟用",
								desc = "啟用時，將會顯示排隊強化技能的強化階段文字。",
								order = 2,
								width = 1.49,
								disabled = function () return data.empowerment.enabled == false end,
							},

							glow = {
								type = "toggle",
								name = "強化時發光",
								desc = "啟用時，技能達到所需的強化階段時將會發光。",
								order = 2.5,
								width = "full",
							},

							position = {
								type = "group",
								inline = true,
								name = function( info ) rangeIcon( info ); return "文字位置" end,
								order = 3,
								args = {
									anchor = {
										type = "select",
										name = '位置',
										order = 1,
										width = 1,
										values = {
											TOP = '上',
											BOTTOM = '下',
										}
									},

									x = {
										type = "range",
										name = "水平位移",
										order = 2,
										width = 0.99,
										step = 1,
									},

									y = {
										type = "range",
										name = "垂直位移",
										order = 3,
										width = 0.99,
										step = 1,
									},

									break01 = {
										type = "description",
										name = " ",
										order = 3.1,
										width = "full",
									},

									align = {
										type = "select",
										name = "對齊方式",
										order = 4,
										width = 1.49,
										values = {
											LEFT = "靠左",
											RIGHT = "靠右",
											CENTER = "居中"
										},
									},
								}
							},

							textStyle = {
								type = "group",
								inline = true,
								name = "文字",
								order = 4,
								args = tableCopy( fontElements ),
							},
						}
					},

                    targets = {
						type = "group",
						name = "目標",
						desc = "目標數量會顯示在技能組的第一個推薦圖示上面。",
						order = 10,
						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "啟用時，插件將會顯示此技能組的活躍 (或虛擬) 目標數量。",
								order = 1,
								width = "full",
							},

							pos = {
								type = "group",
								inline = true,
								name = function( info ) rangeIcon( info ); return "位置" end,
								order = 2,
								args = {
									anchor = {
										type = "select",
										name = "對齊到",
										values = realAnchorPositions,
										order = 1,
										width = 1,
									},

									x = {
										type = "range",
										name = "水平位移",
										min = -max( data.primaryWidth, data.queue.width ),
										max = max( data.primaryWidth, data.queue.width ),
										step = 1,
										order = 2,
										width = 0.99,
									},

									y = {
										type = "range",
										name = "垂直位移",
										min = -max( data.primaryHeight, data.queue.height ),
										max = max( data.primaryHeight, data.queue.height ),
										step = 1,
										order = 2,
										width = 0.99,
									}
								}
							},

							textStyle = {
								type = "group",
								inline = true,
								name = "文字",
								order = 3,
								args = tableCopy( fontElements ),
							},
						}
					},

                    delays = {
						type = "group",
						name = "延遲",
						desc = "當將來某個時間推薦某個技能時，彩色指示器或倒數計時器可以" ..
							"通知有延遲。",
						order = 11,
						args = {
							extend = {
								type = "toggle",
								name = "延長螺旋",
								desc = "勾選時，主圖示的冷卻螺旋將會一直持續，直到應該要使用該技能時。",
								width = 1.49,
								order = 1,
							},

							fade = {
								type = "toggle",
								name = "淡出為不可用",
								desc = "當你在使用該技能之前需要等待時，例如當某個技能缺乏所需資源時，將會淡出主圖示。",
								width = 1.49,
								order = 1.1
							},

							break01 = {
								type = "description",
								name = " ",
								order = 1.2,
								width = "full",
							},

							type = {
								type = "select",
								name = "指示器",
								desc = "指定在施放該能力之前應等待的情況下要使用的指示器類型。",
								values = {
									__NA = "無指示器",
									ICON = "顯示圖示 (顏色)",
									TEXT = "顯示文字 (倒數計時)",
								},
								width = 1.49,
								order = 2,
							},

							pos = {
								type = "group",
								inline = true,
								name = function( info ) rangeIcon( info ); return "位置" end,
								order = 3,
								args = {
									anchor = {
										type = "select",
										name = '位置',
										order = 2,
										width = 1,
										values = realAnchorPositions
									},

									x = {
										type = "range",
										name = "水平位移",
										order = 3,
										width = 0.99,
										min = -max( data.primaryWidth, data.queue.width ),
										max = max( data.primaryWidth, data.queue.width ),
										step = 1,
									},

									y = {
										type = "range",
										name = "垂直位移",
										order = 4,
										width = 0.99,
										min = -max( data.primaryHeight, data.queue.height ),
										max = max( data.primaryHeight, data.queue.height ),
										step = 1,
									}
								},
								disabled = function () return data.delays.type == "__NA" end,
							},

							textStyle = {
								type = "group",
								inline = true,
								name = "文字",
								order = 4,
								args = tableCopy( fontElements ),
								disabled = function () return data.delays.type ~= "TEXT" end,
							},
						}
					},

                    indicators = {
						type = "group",
						name = "指示器",
						desc = "指示器是可以指示目標切換或 (很少) 取消光環的小圖示。",
						order = 11,
						args = {
							enabled = {
								type = "toggle",
								name = "啟用",
								desc = "啟用時，目標切換、光環取消等的小指示器可能會出現在主圖示上。",
								order = 1,
								width = 1.49,
							},

							queued = {
								type = "toggle",
								name = "排隊圖示啟用",
								desc = "啟用時，這些指示器將會出現在排隊圖示以及主圖示上 (如果適合)。",
								order = 2,
								width = 1.49,
								disabled = function () return data.indicators.enabled == false end,
							},

							pos = {
								type = "group",
								inline = true,
								name = function( info ) rangeIcon( info ); return "位置" end,
								order = 2,
								args = {
									anchor = {
										type = "select",
										name = "對齊到",
										values = realAnchorPositions,
										order = 1,
										width = 1,
									},

									x = {
										type = "range",
										name = "水平位移",
										min = -max( data.primaryWidth, data.queue.width ),
										max = max( data.primaryWidth, data.queue.width ),
										step = 1,
										order = 2,
										width = 0.99,
									},

									y = {
										type = "range",
										name = "垂直位移",
										min = -max( data.primaryHeight, data.queue.height ),
										max = max( data.primaryHeight, data.queue.height ),
										step = 1,
										order = 2,
										width = 0.99,
									}
								}
							},
						}
					},
                },
            },
        }

        return option
    end


    function Hekili:EmbedDisplayOptions( db )
		db = db or self.Options
		if not db then return end

		local section = db.args.displays or {
			type = "group",
			name = "技能組",
			childGroups = "tree",
			cmdHidden = true,
			get = 'GetDisplayOption',
			set = 'SetDisplayOption',
			order = 30,

			args = {
				header = {
					type = "description",
					name = "Hekili 輸出助手最多可以有五個內建技能組 (以藍色標示)，可以顯示" ..
						"不同種類的建議。插件的建議是基於" ..
						"優先順序，這些優先順序通常 (但不限於) 基於 SimulationCraft 設定檔，" ..
						"以便你可以將你的表現與模擬結果進行比較。",
					fontSize = "medium",
					width = "full",
					order = 1,
				},

				displays = {
					type = "header",
					name = "技能組",
					order = 10,
				},


				nPanelHeader = {
					type = "header",
					name = "通知面板",
					order = 950,
				},

				nPanelBtn = {
					type = "execute",
					name = "通知面板",
					desc = "通知面板會在戰鬥中更改或" ..
						"切換設定時提供簡要的通知。",
					func = function ()
						ACD:SelectGroup( "Hekili", "displays", "nPanel" )
					end,
					order = 951,
				},

				nPanel = {
					type = "group",
					name = "|cFF1EFF00通知面板|r",
					desc = "通知面板會在戰鬥中更改或" ..
						"切換設定時提供簡要的通知。",
					order = 952,
					get = GetNotifOption,
					set = SetNotifOption,
					args = {
						enabled = {
							type = "toggle",
							name = "啟用",
							order = 1,
							width = "full",
						},

						posRow = {
							type = "group",
							name = function( info ) rangeXY( info, true ); return "位置" end,
							inline = true,
							order = 2,
							args = {
								x = {
									type = "range",
									name = "水平位置",
									desc = "輸入通知面板的水平位置，" ..
										"相對於畫面中心。負值將面板向左移動；正值將面板向右移動。",
									min = -512,
									max = 512,
									step = 1,

									width = 1.49,
									order = 1,
								},

								y = {
									type = "range",
									name = "垂直位置",
									desc = "輸入通知面板的垂直位置，" ..
										"相對於畫面中心。負值將面板向下移動；正值將面板向上移動。",
									min = -384,
									max = 384,
									step = 1,

									width = 1.49,
									order = 2,
								},
							}
						},

						sizeRow = {
							type = "group",
							name = "大小",
							inline = true,
							order = 3,
							args = {
								width = {
									type = "range",
									name = "寬度",
									min = 50,
									max = 1000,
									step = 1,

									width = "full",
									order = 1,
								},

								height = {
									type = "range",
									name = "高度",
									min = 20,
									max = 600,
									step = 1,

									width = "full",
									order = 2,
								},
							}
						},

						fontGroup = {
							type = "group",
							inline = true,
							name = "文字",

							order = 5,
							args = tableCopy( fontElements ),
						},
					}
				},

				fontHeader = {
					type = "header",
					name = "字體",
					order = 960,
				},

				fontWarn = {
					type = "description",
					name = "更改以下字體將會修改|cFFFF0000所有|r技能組上的所有文字。\n" ..
							"要單獨修改一個文字，請選擇技能組 (在左側) 並選擇適當的文字。",
					order = 960.01,
				},

				font = {
					type = "select",
					name = "字體",
					order = 960.1,
					width = 1.5,
					dialogControl = 'LSM30_Font',
					values = LSM:HashTable("font"),
					get = function( info )
						-- 顯示來自主要、鍵盤綁定的資訊。
						return Hekili.DB.profile.displays.Primary.keybindings.font
					end,
					set = function( info, val )
						-- 設定所有技能組中的所有字體。
						for _, display in pairs( Hekili.DB.profile.displays ) do
							for _, data in pairs( display ) do
								if type( data ) == "table" and data.font then data.font = val end
							end
						end
						QueueRebuildUI()
					end,
				},

				fontSize = {
					type = "range",
					name = "大小",
					order = 960.2,
					min = 8,
					max = 64,
					step = 1,
					get = function( info )
						-- 顯示來自主要、鍵盤綁定的資訊。
						return Hekili.DB.profile.displays.Primary.keybindings.fontSize
					end,
					set = function( info, val )
						-- 設定所有技能組中的所有字體。
						for _, display in pairs( Hekili.DB.profile.displays ) do
							for _, data in pairs( display ) do
								if type( data ) == "table" and data.fontSize then data.fontSize = val end
							end
						end
						QueueRebuildUI()
					end,
					width = 1.5,
				},

				fontStyle = {
					type = "select",
					name = "樣式",
					order = 960.3,
					values = {
						["MONOCHROME"] = "無消除鋸齒",
						["MONOCHROME,OUTLINE"] = "無消除鋸齒、邊框",
						["MONOCHROME,THICKOUTLINE"] = "無消除鋸齒、粗邊框",
						["NONE"] = "無",
						["OUTLINE"] = "邊框",
						["THICKOUTLINE"] = "粗邊框"
					},
					get = function( info )
						-- 顯示來自主要、鍵盤綁定的資訊。
						return Hekili.DB.profile.displays.Primary.keybindings.fontStyle
					end,
					set = function( info, val )
						-- 設定所有技能組中的所有字體。
						for _, display in pairs( Hekili.DB.profile.displays ) do
							for _, data in pairs( display ) do
								if type( data ) == "table" and data.fontStyle then data.fontStyle = val end
							end
						end
						QueueRebuildUI()
					end,
					width = 1.5,
				},

				color = {
					type = "color",
					name = "顏色",
					order = 960.4,
					get = function( info )
						return unpack( Hekili.DB.profile.displays.Primary.keybindings.color )
					end,
					set = function( info, ... )
						for name, display in pairs( Hekili.DB.profile.displays ) do
							for _, data in pairs( display ) do
								if type( data ) == "table" and data.color then data.color = { ... } end
							end
						end
						QueueRebuildUI()
					end,
					width = 1.5
				},

				shareHeader = {
					type = "header",
					name = "分享",
					order = 996,
				},

				shareBtn = {
					type = "execute",
					name = "分享樣式",
					desc = "可以透過這些匯出字串將你的技能組樣式與其他插件使用者分享。\n\n" ..
						"你也可以在這裡匯入他人分享的匯出字串。",
					func = function ()
						ACD:SelectGroup( "Hekili", "displays", "shareDisplays" )
					end,
					order = 998,
				},

				shareDisplays = {
					type = "group",
					name = "|cFF1EFF00分享樣式|r",
					desc = "可以透過這些匯出字串將你的技能組樣式與其他插件使用者分享。\n\n" ..
						"你也可以在這裡匯入他人分享的匯出字串。",
					childGroups = "tab",
					get = 'GetDisplayShareOption',
					set = 'SetDisplayShareOption',
					order = 999,
					args = {
						import = {
							type = "group",
							name = "匯入",
							order = 1,
							args = {
								stage0 = {
									type = "group",
									name = "",
									inline = true,
									order = 1,
									args = {
										guide = {
											type = "description",
											name = "選擇一個已儲存的樣式或將匯入字串貼上到提供的方框中。",
											order = 1,
											width = "full",
											fontSize = "medium",
										},

										separator = {
											type = "header",
											name = "匯入字串",
											order = 1.5,
										},

										selectExisting = {
											type = "select",
											name = "選擇一個已儲存的樣式",
											order = 2,
											width = "full",
											get = function()
												return "0000000000"
											end,
											set = function( info, val )
												local style = self.DB.global.styles[ val ]

												if style then shareDB.import = style.payload end
											end,
											values = function ()
												local db = self.DB.global.styles
												local values = {
													["0000000000"] = "選擇一個已儲存的樣式"
												}

												for k, v in pairs( db ) do
													values[ k ] = k .. " (|cFF00FF00" .. v.date .. "|r)"
												end

												return values
											end,
										},

										importString = {
											type = "input",
											name = "匯入字串",
											get = function () return shareDB.import end,
											set = function( info, val )
												val = val:trim()
												shareDB.import = val
											end,
											order = 3,
											multiline = 5,
											width = "full",
										},

										btnSeparator = {
											type = "header",
											name = "匯入",
											order = 4,
										},

										importBtn = {
											type = "execute",
											name = "匯入樣式",
											order = 5,
											func = function ()
												shareDB.imported, shareDB.error = DeserializeStyle( shareDB.import )

												if shareDB.error then
													shareDB.import = "提供的匯入字串無法解壓縮。\n" .. shareDB.error
													shareDB.error = nil
													shareDB.imported = {}
												else
													shareDB.importStage = 1
												end
											end,
											disabled = function ()
												return shareDB.import == ""
											end,
										},
									},
									hidden = function () return shareDB.importStage ~= 0 end,
								},

								stage1 = {
									type = "group",
									inline = true,
									name = "",
									order = 1,
									args = {
										guide = {
											type = "description",
											name = function ()
												local creates, replaces = {}, {}

												for k, v in pairs( shareDB.imported ) do
													if rawget( self.DB.profile.displays, k ) then
														insert( replaces, k )
													else
														insert( creates, k )
													end
												end

												local o = ""

												if #creates > 0 then
													o = o .. "匯入的樣式將會建立以下技能組:  "
													for i, display in orderedPairs( creates ) do
														if i == 1 then o = o .. display
														else o = o .. "、" .. display end
													end
													o = o .. "。\n"
												end

												if #replaces > 0 then
													o = o .. "匯入的樣式將會覆蓋以下技能組:  "
													for i, display in orderedPairs( replaces ) do
														if i == 1 then o = o .. display
														else o = o .. "、" .. display end
													end
													o = o .. "。"
												end

												return o
											end,
											order = 1,
											width = "full",
											fontSize = "medium",
										},

										separator = {
											type = "header",
											name = "套用變更",
											order = 2,
										},

										apply = {
											type = "execute",
											name = "套用變更",
											order = 3,
											confirm = true,
											func = function ()
												for k, v in pairs( shareDB.imported ) do
													if type( v ) == "table" then self.DB.profile.displays[ k ] = v end
												end

												shareDB.import = ""
												shareDB.imported = {}
												shareDB.importStage = 2

												self:EmbedDisplayOptions()
												QueueRebuildUI()
											end,
										},

										reset = {
											type = "execute",
											name = "重置",
											order = 4,
											func = function ()
												shareDB.import = ""
												shareDB.imported = {}
												shareDB.importStage = 0
											end,
										},
									},
									hidden = function () return shareDB.importStage ~= 1 end,
								},

								stage2 = {
									type = "group",
									inline = true,
									name = "",
									order = 3,
									args = {
										note = {
											type = "description",
											name = "已成功套用匯入的設定！\n\n如果需要，請點 '重置' 以重新開始。",
											order = 1,
											fontSize = "medium",
											width = "full",
										},

										reset = {
											type = "execute",
											name = "重置",
											order = 2,
											func = function ()
												shareDB.import = ""
												shareDB.imported = {}
												shareDB.importStage = 0
											end,
										}
									},
									hidden = function () return shareDB.importStage ~= 2 end,
								}
							},
							plugins = {
							}
						},

						export = {
							type = "group",
							name = "匯出",
							order = 2,
							args = {
								stage0 = {
									type = "group",
									name = "",
									inline = true,
									order = 1,
									args = {
										guide = {
											type = "description",
											name = "選擇要匯出的技能組樣式設定，然後點 '匯出樣式' 以產生匯出字串。",
											order = 1,
											fontSize = "medium",
											width = "full",
										},

										displays = {
											type = "header",
											name = "技能組",
											order = 2,
										},

										exportHeader = {
											type = "header",
											name = "匯出",
											order = 1000,
										},

										exportBtn = {
											type = "execute",
											name = "匯出樣式",
											order = 1001,
											func = function ()
												local disps = {}
												for key, share in pairs( shareDB.displays ) do
													if share then insert( disps, key ) end
												end

												shareDB.export = SerializeStyle( unpack( disps ) )
												shareDB.exportStage = 1
											end,
											disabled = function ()
												local hasDisplay = false

												for key, value in pairs( shareDB.displays ) do
													if value then hasDisplay = true; break end
												end

												return not hasDisplay
											end,
										},
									},
									plugins = {
										displays = {}
									},
									hidden = function ()
										local plugins = self.Options.args.displays.args.shareDisplays.args.export.args.stage0.plugins.displays
										wipe( plugins )

										local i = 1
										for dispName, display in pairs( self.DB.profile.displays ) do
											local pos = 20 + ( display.builtIn and display.order or i )
											plugins[ dispName ] = {
												type = "toggle",
												name = function ()
													if display.builtIn then return "|cFF00B4FF" .. dispName .. "|r" end
													return dispName
												end,
												order = pos,
												width = "full"
											}
											i = i + 1
										end

										return shareDB.exportStage ~= 0
									end,
								},

								stage1 = {
									type = "group",
									name = "",
									inline = true,
									order = 1,
									args = {
										exportString = {
											type = "input",
											name = "樣式字串",
											order = 1,
											multiline = 8,
											get = function () return shareDB.export end,
											set = function () end,
											width = "full",
											hidden = function () return shareDB.export == "" end,
										},

										instructions = {
											type = "description",
											name = "你可以複製上述字串以分享你選擇的技能組樣式設定，或" ..
												"使用以下選項來儲存這些設定 (以便日後檢索)。",
											order = 2,
											width = "full",
											fontSize = "medium"
										},

										store = {
											type = "group",
											inline = true,
											name = "",
											order = 3,
											hidden = function () return shareDB.export == "" end,
											args = {
												separator = {
													type = "header",
													name = "儲存樣式",
													order = 1,
												},

												exportName = {
													type = "input",
													name = "樣式名稱",
													get = function () return shareDB.styleName end,
													set = function( info, val )
														val = val:trim()
														shareDB.styleName = val
													end,
													order = 2,
													width = "double",
												},

												storeStyle = {
													type = "execute",
													name = "儲存匯出字串",
													desc = "通過儲存匯出字串，可以儲存這些技能組設定，並在你對設定進行更改後稍後檢索它們。\n\n" ..
														"儲存的樣式可以從你的任何角色中檢索，即使使用的是不同的設定檔。",
													order = 3,
													confirm = function ()
														if shareDB.styleName and self.DB.global.styles[ shareDB.styleName ] ~= nil then
															return "已存在名稱為 '" .. shareDB.styleName .. "' 的樣式 -- 要覆蓋它嗎?"
														end
														return false
													end,
													func = function ()
														local db = self.DB.global.styles
														db[ shareDB.styleName ] = {
															date = tonumber( date("%Y%m%d.%H%M%S") ),
															payload = shareDB.export,
														}
														shareDB.styleName = ""
													end,
													disabled = function ()
														return shareDB.export == "" or shareDB.styleName == ""
													end,
												}
											}
										},


										restart = {
											type = "execute",
											name = "重新開始",
											order = 4,
											func = function ()
												shareDB.styleName = ""
												shareDB.export = ""
												wipe( shareDB.displays )
												shareDB.exportStage = 0
											end,
										}
									},
									hidden = function () return shareDB.exportStage ~= 1 end
								}
							},
							plugins = {
								displays = {}
							},
						}
					}
				},
			},
			plugins = {},
		}
		db.args.displays = section
		wipe( section.plugins )

		local i = 1

		for name, data in pairs( self.DB.profile.displays ) do
			local pos = data.builtIn and data.order or i
			section.plugins[ name ] = newDisplayOption( db, name, data, pos )
			if not data.builtIn then i = i + 1 end
		end

		section.plugins[ "Multi" ] = newDisplayOption( db, "Multi", self.DB.profile.displays[ "Primary" ], 0 )
		MakeMultiDisplayOption( section.plugins, section.plugins.Multi.Multi.args )
	end
end


do
    local impControl = {
        name = "",
        source = UnitName( "player" ) .. " @ " .. GetRealmName(),
        apl = "在這裡貼上你的 SimulationCraft 動作優先順序列表或設定檔。",

        lists = {},
        warnings = ""
    }

    Hekili.ImporterData = impControl


    local function AddWarning( s )
        if impControl.warnings then
            impControl.warnings = impControl.warnings .. s .. "\n"
            return
        end

        impControl.warnings = s .. "\n"
    end


    function Hekili:GetImporterOption( info )
        return impControl[ info[ #info ] ]
    end


    function Hekili:SetImporterOption( info, value )
        if type( value ) == 'string' then value = value:trim() end
        impControl[ info[ #info ] ] = value
        impControl.warnings = nil
    end


    function Hekili:ImportSimcAPL( name, source, apl, pack )

        name = name or impControl.name
        source = source or impControl.source
        apl = apl or impControl.apl

        impControl.warnings = ""

        local lists = {
            precombat = "",
            default = "",
        }

        local count = 0

        -- Rename the default action list to 'default'
        apl = "\n" .. apl
        apl = apl:gsub( "actions(%+?)=", "actions.default%1=" )

        local comment

        for line in apl:gmatch( "\n([^\n^$]*)") do
            local newComment = line:match( "^# (.+)" )
            if newComment then comment = newComment end

            local list, action = line:match( "^actions%.(%S-)%+?=/?([^\n^$]*)" )

            if list and action then
                lists[ list ] = lists[ list ] or ""

                if action:sub( 1, 16 ) == "call_action_list" or action:sub( 1, 15 ) == "run_action_list" then
                    local name = action:match( ",name=(.-)," ) or action:match( ",name=(.-)$" )
                    if name then action:gsub( ",name=" .. name, ",name=\"" .. name .. "\"" ) end
                end

                if comment then
                    action = action .. ',description=' .. comment:gsub( ",", ";" )
                    comment = nil
                end

                lists[ list ] = lists[ list ] .. "actions+=/" .. action .. "\n"
            end
        end

        if lists.precombat:len() == 0 then lists.precombat = "actions+=/heart_essence,enabled=0" end
        if lists.default  :len() == 0 then lists.default   = "actions+=/heart_essence,enabled=0" end

        local count = 0
        local output = {}

        for name, list in pairs( lists ) do
            local import, warnings = self:ParseActionList( list )

            if warnings then
                AddWarning( "匯入 '" .. name .. "' 需要一些自動更改。" )

                for i, warning in ipairs( warnings ) do
                    AddWarning( warning )
                end

                AddWarning( "" )
            end

            if import then
                output[ name ] = import

                for i, entry in ipairs( import ) do
                    if entry.enabled == nil then entry.enabled = not ( entry.action == 'heroism' or entry.action == 'bloodlust' )
                    elseif entry.enabled == "0" then entry.enabled = false end
                end

                count = count + 1
            end
        end

        local use_items_found = false
        local trinket1_found = false
        local trinket2_found = false

        for _, list in pairs( output ) do
            for i, entry in ipairs( list ) do
                if entry.action == "use_items" then use_items_found = true
                elseif entry.action == "trinket1" then trinket1_found = true
                elseif entry.action == "trinket2" then trinket2_found = true end
            end
        end

        if not use_items_found and not ( trinket1_found and trinket2_found ) then
			AddWarning( "這個設定檔缺少對通用飾品的支援。建議每個優先順序都包含以下其中一項：\n" ..
				" - [使用物品]，其中包含優先順序中未明確包含的任何飾品；或\n" ..
				" - [飾品 1] 和 [飾品 2]，將會推薦編號位置的飾品。" )
		end

		if not output.default then output.default = {} end
		if not output.precombat then output.precombat = {} end

		if count == 0 then
			AddWarning( "沒有從此設定檔匯入任何動作列表。" )
		else
			AddWarning( "已匯入 " .. count .. " 個動作列表。" )
		end

        return output, impControl.warnings
    end
end


local snapshots = {
    snaps = {},
    empty = {},

    selected = 0
}


local config = {
    qsDisplay = 99999,

    qsShowTypeGroup = false,
    qsDisplayType = 99999,
    qsTargetsAOE = 3,

    displays = {}, -- auto-populated and recycled.
    displayTypes = {
        [1] = "Primary",
        [2] = "AOE",
        [3] = "Automatic",
        [99999] = " "
    },

    expanded = {
        cooldowns = true
    },
    adding = {},
}


local specs = {}
local activeSpec

local function GetCurrentSpec()
    activeSpec = activeSpec or GetSpecializationInfo( GetSpecialization() )
    return activeSpec
end

local function SetCurrentSpec( _, val )
    activeSpec = val
end

local function GetCurrentSpecList()
    return specs
end


do
    local packs = {}

    local specNameByID = {}
    local specIDByName = {}

    local shareDB = {
        actionPack = "",
        packName = "",
        export = "",

        import = "",
        imported = {},
        importStage = 0
    }


    function Hekili:GetPackShareOption( info )
        local n = #info
        local option = info[ n ]

        return shareDB[ option ]
    end


    function Hekili:SetPackShareOption( info, val, v2, v3, v4 )
        local n = #info
        local option = info[ n ]

        if type(val) == 'string' then val = val:trim() end

        shareDB[ option ] = val

        if option == "actionPack" and rawget( self.DB.profile.packs, shareDB.actionPack ) then
            shareDB.export = SerializeActionPack( shareDB.actionPack )
        else
            shareDB.export = ""
        end
    end


    function Hekili:SetSpecOption( info, val )
        local n = #info
        local spec, option = info[1], info[n]

        spec = specIDByName[ spec ]
        if not spec then return end

        if type( val ) == 'string' then val = val:trim() end

        self.DB.profile.specs[ spec ] = self.DB.profile.specs[ spec ] or {}
        self.DB.profile.specs[ spec ][ option ] = val

        if option == "package" then self:UpdateUseItems(); self:ForceUpdate( "SPEC_PACKAGE_CHANGED" )
        elseif option == "enabled" then ns.StartConfiguration() end

        Hekili:UpdateDamageDetectionForCLEU()
    end


    function Hekili:GetSpecOption( info )
        local n = #info
        local spec, option = info[1], info[n]

        spec = specIDByName[ spec ]
        if not spec then return end

        self.DB.profile.specs[ spec ] = self.DB.profile.specs[ spec ] or {}

        if option == "potion" then
            local p = self.DB.profile.specs[ spec ].potion

            if not class.potionList[ p ] then
                return class.potions[ p ] and class.potions[ p ].key or p
            end
        end

        return self.DB.profile.specs[ spec ][ option ]
    end


    function Hekili:SetSpecPref( info, val )
    end

    function Hekili:GetSpecPref( info )
    end


    function Hekili:SetAbilityOption( info, val )
        local n = #info
        local ability, option = info[2], info[n]

        local spec = GetCurrentSpec()

        self.DB.profile.specs[ spec ].abilities[ ability ][ option ] = val
        if option == "toggle" then Hekili:EmbedAbilityOption( nil, ability ) end
    end

    function Hekili:GetAbilityOption( info )
        local n = #info
        local ability, option = info[2], info[n]

        local spec = GetCurrentSpec()

        return self.DB.profile.specs[ spec ].abilities[ ability ][ option ]
    end


    function Hekili:SetItemOption( info, val )
        local n = #info
        local item, option = info[2], info[n]

        local spec = GetCurrentSpec()

        self.DB.profile.specs[ spec ].items[ item ][ option ] = val
        if option == "toggle" then Hekili:EmbedItemOption( nil, item ) end
    end

    function Hekili:GetItemOption( info )
        local n = #info
        local item, option = info[2], info[n]

        local spec = GetCurrentSpec()

        return self.DB.profile.specs[ spec ].items[ item ][ option ]
    end


    function Hekili:EmbedAbilityOption( db, key )
		db = db or self.Options
		if not db or not key then return end

		local ability = class.abilities[ key ]
		if not ability then return end

		local toggles = {}

		local k = class.abilityList[ ability.key ]
		local v = ability.key

		if not k or not v then return end

		local useName = class.abilityList[ v ] and class.abilityList[v]:match("|t (.+)$") or ability.name

		if not useName then
			Hekili:Error( "EmbedAbilityOption 中 %s (id:%d) 沒有可用的名稱。", ability.key or "no_id", ability.id or 0 )
			useName = ability.key or ability.id or "???"
		end

		local option = db.args.abilities.plugins.actions[ v ] or {}

		option.type = "group"
		option.name = function () return useName .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end
		option.order = 1
		option.set = "SetAbilityOption"
		option.get = "GetAbilityOption"
		option.args = {
			disabled = {
				type = "toggle",
				name = function () return "停用 " .. ( ability.item and ability.link or k ) end,
				desc = function () return "勾選時，插件將|cffff0000永遠不會|r推薦此技能。這可能會導致" ..
					"某些專精出現問題，如果其他技能依賴於使用 |W" .. ( ability.item and ability.link or k ) .. "|w。" end,
				width = 2,
				order = 1,
			},

			boss = {
				type = "toggle",
				name = "只有首領戰",
				desc = "勾選時，插件將不會推薦 |W" .. k .. "|w，除非你正在進行首領戰 (或遭遇戰)。如果未勾選，則 |W" .. k .. "|w 可以在任何類型的戰鬥中被推薦。",
				width = 2,
				order = 1.1,
			},

			keybind = {
				type = "input",
				name = "覆蓋按鍵綁定文字",
				desc = function()
					local output = "有指定時，插件將會在推薦此技能時顯示此文字，而不是自動偵測到的按鍵綁定文字。 " ..
						"如果你的按鍵綁定被錯誤偵測或在多個快捷列上找到，這將會很有幫助。"

					local detected = Hekili.KeybindInfo and Hekili.KeybindInfo[ ability.key ]
					if detected then
						output = output .. "\n"

						for page, text in pairs( detected.upper ) do
							output = format( "%s\n|cFFFFD100%s|r 在快捷列頁面 |cFFFFD100%d 上偵測到。", output, text, page )
						end
					else
						output = output .. "\n|cFFFFD100未偵測到此技能的按鍵綁定。|r"
					end

					return output
				end,
				validate = function( info, val )
					val = val:trim()
					if val:len() > 20 then return "按鍵綁定的長度不應超過 20 個字元。" end
					return true
				end,
				width = 2,
				order = 3,
			},

			toggle = {
				type = "select",
				name = "需要切換",
				desc = "指定在插件動作列表中使用此動作所需的切換。當切換關閉時，技能將被視為" ..
					"不可用，並且插件會假設它們正在冷卻中 (除非有另外指定)。",
				width = 1.5,
				order = 2,
				values = function ()
					table.wipe( toggles )

					local t = class.abilities[ v ].toggle or "none"
					if t == "essences" then t = "covenants" end

					toggles.none = "無"
					toggles.default = "預設 |cffffd100(" .. t .. ")|r"
					toggles.cooldowns = "冷卻時間"
					toggles.essences = "小型冷卻時間"
					toggles.defensives = "防禦技能"
					toggles.interrupts = "斷法技能"
					toggles.potions = "藥水"
					toggles.custom1 = "自訂 1"
					toggles.custom2 = "自訂 2"

					return toggles
				end,
			},

			targetMin = {
				type = "range",
				name = "最小目標數",
				desc = "如果設定大於 0，則只有當偵測到至少有這麼多敵人時，插件才會允許推薦 " .. k .. "。所有其他動作列表條件也必須滿足。\n設定為 0 以忽略。",
				width = 1.5,
				min = 0,
				softMax = 15,
				max = 100,
				step = 1,
				order = 3.1,
			},

			targetMax = {
				type = "range",
				name = "最大目標數",
				desc = "如果設定大於 0，則只有當偵測到的敵人數量等於或少於此設定值時，插件才會允許推薦 " .. k .. "。所有其他動作列表條件也必須滿足。\n設定為 0 以忽略。",
				width = 1.5,
				min = 0,
				max = 15,
				step = 1,
				order = 3.2,
			},

			clash = {
				type = "range",
				name = "衝突",
				desc = "如果設定大於 0，插件將會假設 " .. k .. " 比實際上更早結束冷卻時間。  " ..
					"當技能的優先順序非常高，並且你希望插件優先選擇它，而不是較早可用的技能時，這會很有幫助。",
				width = 3,
				min = -1.5,
				max = 1.5,
				step = 0.05,
				order = 4,
			},
		}

		db.args.abilities.plugins.actions[ v ] = option
	end



    local testFrame = CreateFrame( "Frame" )
    testFrame.Texture = testFrame:CreateTexture()

    function Hekili:EmbedAbilityOptions( db )
        db = db or self.Options
        if not db then return end

        local abilities = {}
        local toggles = {}

        for k, v in pairs( class.abilityList ) do
            local a = class.abilities[ k ]
            if a and a.id and ( a.id > 0 or a.id < -100 ) and a.id ~= 61304 and not a.item then
                abilities[ v ] = k
            end
        end

        for k, v in orderedPairs( abilities ) do
            local ability = class.abilities[ v ]
            local useName = class.abilityList[ v ] and class.abilityList[v]:match("|t (.+)$") or ability.name

            if not useName then
                Hekili:Error( "EmbedAbilityOption 中 %s (id:%d) 沒有可用的名稱。", ability.key or "no_id", ability.id or 0 )
                useName = ability.key or ability.id or "???"
            end

            local option = {
                type = "group",
                name = function () return useName .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end,
                order = 1,
                set = "SetAbilityOption",
                get = "GetAbilityOption",
                args = {
                    disabled = {
                        type = "toggle",
                        name = function () return "停用 " .. ( ability.item and ability.link or k ) end,
                        desc = function () return "勾選時，插件將|cffff0000永遠不會|r推薦此技能。這可能會導致" ..
                            "某些專精出現問題，如果其他技能依賴於你使用 |W" .. ( ability.item and ability.link or k ) .. "。" end,
                        width = 1.5,
                        order = 1,
                    },

                    boss = {
                        type = "toggle",
                        name = "只有首領戰",
						desc = "勾選時，插件將不會推薦 |W" .. k .. "|w，除非你正在進行首領戰 (或遭遇戰)。如果未勾選，則 |W" .. k .. "|w 可以在任何類型的戰鬥中被推薦。",
                        width = 1.5,
                        order = 1.1,
                    },

                    lineBreak1 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 1.9
                    },

                    toggle = {
                        type = "select",
                        name = "需要切換",
						desc = "指定在插件動作列表中使用此動作所需的切換。當切換關閉時，技能將被視為" ..
							"不可用，並且插件會假設它們正在冷卻中 (除非有另外指定)。",
                        width = 1.5,
                        order = 1.2,
                        values = function ()
                            table.wipe( toggles )

                            local t = class.abilities[ v ].toggle or "none"
                            if t == "essences" then t = "covenants" end

                            toggles.none = "無"
							toggles.default = "預設 |cffffd100(" .. t .. ")|r"
							toggles.cooldowns = "冷卻時間"
							toggles.essences = "次要冷卻時間"
							toggles.defensives = "防禦技能"
							toggles.interrupts = "斷法技能"
							toggles.potions = "藥水"
							toggles.custom1 = "自訂 1"
							toggles.custom2 = "自訂 2"

                            return toggles
                        end,
                    },

                    lineBreak5 = {
                        type = "description",
                        name = "",
                        width = "full",
                        order = 1.29,
                    },

                    -- Test Option for Separate Cooldowns
                    noFeignedCooldown = {
                        type = "toggle",
                        name = "|cFFFFD100(整體)|r 單獨顯示冷卻時間時，使用實際冷卻時間",
                        desc = "勾選時|cFFFFD100和|r單獨顯示冷卻|cFFFFD100和|r已啟用冷卻時間，插件將|cFFFF0000不會|r假裝你的" ..
                            "冷卻技能已經完全冷卻。\n\n這可能有助於解決由於冷卻時間顯示和其他顯示之間的行為差異" ..
                            "而導致技能不同步的情況。\n\n" ..
                            "請看 |cFFFFD100切換|r > |cFFFFD100冷卻時間|r 以取得 |cFFFFD100冷卻時間: 單獨顯示|r 的功能。",
                        set = function()
                            self.DB.profile.specs[ state.spec.id ].noFeignedCooldown = not self.DB.profile.specs[ state.spec.id ].noFeignedCooldown
                        end,
                        get = function()
                            return self.DB.profile.specs[ state.spec.id ].noFeignedCooldown
                        end,
                        order = 1.3,
                        width = 3,
                    },

                    lineBreak4 = {
                        type = "description",
                        name = "",
                        width = "full",
                        order = 1.9,
                    },

                    targetMin = {
                        type = "range",
                        name = "最小目標數",
						desc = "如果設定大於 0，則只有當偵測到至少有這麼多敵人時，插件才會允許推薦 " .. k .. "。所有其他動作列表條件也必須滿足。\n設定為 0 以忽略。",
                        width = 1.5,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 2,
                    },

                    targetMax = {
                        type = "range",
                        name = "最大目標數",
						desc = "如果設定大於 0，則只有當偵測到的敵人數量等於或少於此設定值時，插件才會允許推薦 " .. k .. "。所有其他動作列表條件也必須滿足。\n設定為 0 以忽略。",
                        width = 1.5,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 2.1,
                    },

                    lineBreak2 = {
                        type = "description",
                        name = "",
                        width = "full",
                        order = 2.11,
                    },

                    clash = {
                        type = "range",
                        name = "衝突",
                        desc = "如果設定大於 0，插件將會假設 " .. k .. " 比實際上更早冷卻完成。  " ..
							"當技能的優先順序非常高，並且你希望插件優先選擇它，而不是其他較早可用的技能時，這會很有幫助。",
                        width = 3,
                        min = -1.5,
                        max = 1.5,
                        step = 0.05,
                        order = 2.2,
                    },


                    lineBreak3 = {
                        type = "description",
                        name = "",
                        width = "full",
                        order = 2.3,
                    },

                    keybind = {
                        type = "input",
                        name = "覆蓋按鍵綁定文字",
                        desc = function()
                            local output = "有指定時，插件將會在推薦此技能時顯示此文字，而不是自動偵測到的按鍵綁定文字。 " ..
								"如果你的按鍵綁定被錯誤偵測或在多個快捷列上找到，這將會很有幫助。"

                            local detected = Hekili.KeybindInfo and Hekili.KeybindInfo[ ability.key ]
                            local found = false

                            if detected then
                                for page, text in pairs( detected.upper ) do
                                    if found == false then output = output .. "\n"; found = true end
                                    output = format( "%s\n|cFFFFD100%s|r 在快捷列頁面 |cFFFFD100%d 上偵測到。", output, text, page )
                                end
                            end

                            if not found then
                                output = format( "%s\n|cFFFFD100未偵測到此技能的按鍵綁定。|r", output )
                            end

                            return output
                        end,
                        validate = function( info, val )
                            val = val:trim()
                            if val:len() > 6 then return "按鍵綁定的長度不應超過 20 個字元。" end
                            return true
                        end,
                        width = 1.5,
                        order = 3,
                    },

                    noIcon = {
                        type = "input",
                        name = "圖示替換",
                        desc = "有指定時，插件會嘗試載入此材質而不是預設圖示。這可以是材質 ID 或材質檔案的路徑。\n\n" ..
								"留空並按 Enter 鍵以重設為預設圖示。",
                        icon = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and options[ v ] and options[ v ].icon or nil
                        end,
                        validate = function( info, val )
                            val = val:trim()
                            testFrame.Texture:SetTexture( "?" )
                            testFrame.Texture:SetTexture( val )
                            return testFrame.Texture:GetTexture() ~= "?"
                        end,
                        set = function( info, val )
                            val = val:trim()
                            if val:len() == 0 then val = nil end

                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            options[ v ].icon = val
                        end,
                        hidden = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return ( options and rawget( options, v ) and options[ v ].icon )
                        end,
                        width = 1.5,
                        order = 3.1,
                    },

                    hasIcon = {
                        type = "input",
                        name = "圖示替換",
                        desc = "有指定時，插件會嘗試載入此材質而不是預設圖示。這可以是材質 ID 或材質檔案的路徑。\n\n" ..
								"留空並按 Enter 鍵以重設為預設圖示。",
                        icon = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and options[ v ] and options[ v ].icon or nil
                        end,
                        validate = function( info, val )
                            val = val:trim()
                            testFrame.Texture:SetTexture( "?" )
                            testFrame.Texture:SetTexture( val )
                            return testFrame.Texture:GetTexture() ~= "?"
                        end,
                        get = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and rawget( options, v ) and options[ v ].icon
                        end,
                        set = function( info, val )
                            val = val:trim()
                            if val:len() == 0 then val = nil end

                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            options[ v ].icon = val
                        end,
                        hidden = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return not ( options and rawget( options, v ) and options[ v ].icon )
                        end,
                        width = 1.3,
                        order = 3.2,
                    },

                    showIcon = {
                        type = 'description',
                        name = "",
                        image = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and rawget( options, v ) and options[ v ].icon
                        end,
                        width = 0.2,
                        order = 3.3,
                    }
                }
            }

            db.args.abilities.plugins.actions[ v ] = option
        end
    end


    function Hekili:EmbedItemOption( db, item )
		db = db or self.Options
		if not db then return end

		local ability = class.abilities[ item ]
		local toggles = {}

		local k = class.itemList[ ability.item ] or ability.name
		local v = ability.itemKey or ability.key

		if not item or not ability.item or not k then
			Hekili:Error( "在物品列表中找不到 %s / %s / %s。", item or "未知", ability.item or "未知", k or "未知" )
			return
		end

		local option = db.args.items.plugins.equipment[ v ] or {}

		option.type = "group"
		option.name = function () return ability.name .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end
		option.order = 1
		option.set = "SetItemOption"
		option.get = "GetItemOption"
		option.args = {
			disabled = {
				type = "toggle",
				name = function () return "停用 " .. ( ability.item and ability.link or k ) end,
				desc = function () return "勾選時，插件將|cffff0000永遠不會|r推薦此技能。這可能會導致" ..
					"某些專精出現問題，如果其他技能依賴於你使用 " .. ( ability.item and ability.link or k ) .. "。" end,
				width = 1.5,
				order = 1,
			},

			boss = {
				type = "toggle",
				name = "只有首領戰",
				desc = "勾選時，插件將不會透過 [使用物品] 推薦 " .. k .. "，除非你正在進行首領戰 (或遭遇戰)。如未勾選，則 " .. k .. " 可以在任何類型的戰鬥中被推薦。",
				width = 1.5,
				order = 1.1,
			},

			keybind = {
				type = "input",
				name = "覆蓋按鍵綁定文字",
				desc = "有指定時，插件將會在推薦此技能時顯示此文字，而不是自動偵測到的按鍵綁定文字。 " ..
					"如果插件錯誤地偵測到你的按鍵綁定，這將會很有幫助。",
				validate = function( info, val )
					val = val:trim()
					if val:len() > 6 then return "按鍵綁定的長度不應超過 6 個字元。" end
					return true
				end,
				width = 1.5,
				order = 2,
			},

			toggle = {
				type = "select",
				name = "需要切換",
				desc = "指定在插件動作列表中使用此動作所需的切換。當切換關閉時，技能將被視為" ..
						"不可用，並且插件會假設它們正在冷卻中 (除非有另外指定)。",
				width = 1.5,
				order = 3,
				values = function ()
					table.wipe( toggles )

					toggles.none = "無"
					toggles.default = "預設" .. ( class.abilities[ v ].toggle and ( " |cffffd100(" .. class.abilities[ v ].toggle .. ")|r" ) or " |cffffd100(無)|r" )
					toggles.cooldowns = "冷卻時間"
					toggles.essences = "次要冷卻時間"
					toggles.defensives = "防禦技能"
					toggles.interrupts = "打斷技能"
					toggles.potions = "藥水"
					toggles.custom1 = "自訂 1"
					toggles.custom2 = "自訂 2"

					return toggles
				end,
			},

			--[[ clash = {
				type = "range",
				name = "Clash",
				desc = "If set above zero, the addon will pretend " .. k .. " has come off cooldown this much sooner than it actually has.  " ..
					"This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner.",
				width = "full",
				min = -1.5,
				max = 1.5,
				step = 0.05,
				order = 4,
			}, ]]

			targetMin = {
				type = "range",
				name = "最小目標數",
				desc = "如果設定大於 0，則只有當偵測到至少有這麼多敵人時，插件才會允許透過 [使用物品] 推薦 " .. k .. "。\n設定為 0 以忽略。",
				width = 1.5,
				min = 0,
				max = 15,
				step = 1,
				order = 5,
			},

			targetMax = {
				type = "range",
				name = "最大目標數",
				desc = "如果設定大於 0，則只有當偵測到的敵人數量等於或少於此設定值時，插件才會允許透過 [使用物品] 推薦 " .. k .. "。\n設定為 0 以忽略。",
				width = 1.5,
				min = 0,
				max = 15,
				step = 1,
				order = 6,
			},
		}

		db.args.items.plugins.equipment[ v ] = option
	end


    function Hekili:EmbedItemOptions( db )
        db = db or self.Options
        if not db then return end

        local abilities = {}
        local toggles = {}

        for k, v in pairs( class.abilities ) do
            if k == "potion" or v.item and not abilities[ v.itemKey or v.key ] then
                local name = class.itemList[ v.item ] or v.name
                if name then abilities[ name ] = v.itemKey or v.key end
            end
        end

        for k, v in orderedPairs( abilities ) do
            local ability = class.abilities[ v ]
            local option = {
                type = "group",
                name = function () return ability.name .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end,
                order = 1,
                set = "SetItemOption",
                get = "GetItemOption",
                args = {
                    multiItem = {
                        type = "description",
                        name = function ()
                            return "這些設定將會套用到|cFF00FF00所有|r " .. ability.name .. " PvP 飾品。"
                        end,
                        fontSize = "medium",
                        width = "full",
                        order = 1,
                        hidden = function () return ability.key ~= "gladiators_badge" and ability.key ~= "gladiators_emblem" and ability.key ~= "gladiators_medallion" end,
                    },

                    disabled = {
                        type = "toggle",
                        name = function () return "停用 " .. ( ability.item and ability.link or k ) end,
                        desc = function () return "勾選時，插件將|cffff0000永遠不會|r推薦此技能。這可能會導致" ..
                            "某些專精出現問題，如果其他技能依賴於你使用 " .. ( ability.item and ability.link or k ) .. "。" end,
                        width = 1.5,
                        order = 1.05,
                    },

                    boss = {
                        type = "toggle",
                        name = "只有首領戰",
                        desc = "勾選時，插件將不會透過 [使用物品] 推薦 " .. ( ability.item and ability.link or k ) .. " ，除非你正在進行首領戰 (或遭遇戰)。如未勾選，則 " .. ( ability.item and ability.link or k ) .. " 可以在任何類型的戰鬥中被推薦。",
                        width = 1.5,
                        order = 1.1,
                    },

                    keybind = {
                        type = "input",
                        name = "覆蓋按鍵綁定文字",
                        desc = "有指定時，插件將會在推薦此技能時顯示此文字，而不是自動偵測到的按鍵綁定文字。  " ..
                            "如果插件錯誤地偵測到你的按鍵綁定，這將會很有幫助。",
                        validate = function( info, val )
                            val = val:trim()
                            if val:len() > 6 then return "按鍵綁定的長度不應超過 6 個字元。" end
                            return true
                        end,
                        width = 1.5,
                        order = 2,
                    },

                    toggle = {
                        type = "select",
                        name = "需要切換",
                        desc = "指定在插件動作列表中使用此動作所需的切換。當切換關閉時，技能將被視為" ..
                            "不可用，並且插件會假設它們正在冷卻中 (除非有另外指定)。",
                        width = 1.5,
                        order = 3,
                        values = function ()
                            table.wipe( toggles )

                            toggles.none = "無"
                            toggles.default = "預設" .. ( class.abilities[ v ].toggle and ( " |cffffd100(" .. class.abilities[ v ].toggle .. ")|r" ) or " |cffffd100(無)|r" )
                            toggles.cooldowns = "冷卻時間"
							toggles.essences = "次要冷卻時間"
							toggles.defensives = "防禦技能"
							toggles.interrupts = "打斷技能"
							toggles.potions = "藥水"
							toggles.custom1 = "自訂 1"
							toggles.custom2 = "自訂 2"

                            return toggles
                        end,
                    },

                    --[[ clash = {
                        type = "range",
                        name = "Clash",
                        desc = "If set above zero, the addon will pretend " .. k .. " has come off cooldown this much sooner than it actually has.  " ..
                            "This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner.",
                        width = "full",
                        min = -1.5,
                        max = 1.5,
                        step = 0.05,
                        order = 4,
                    }, ]]

                    targetMin = {
                        type = "range",
                        name = "最小目標數",
                        desc = "如果設定大於 0，則只有當偵測到至少有這麼多敵人時，插件才會允許透過 [使用物品] 推薦 " .. ( ability.item and ability.link or k ) .. " 。\n設定為 0 以忽略。",
                        width = 1.5,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 5,
                    },

                    targetMax = {
                        type = "range",
                        name = "最大目標數",
                        desc = "如果設定大於 0，則只有當偵測到的敵人數量等於或少於此設定值時，插件才會允許透過 [使用物品] 推薦 " .. ( ability.item and ability.link or k ) .. "。\n設定為 0 以忽略。",
                        width = 1.5,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 6,
                    },
                }
            }

            db.args.items.plugins.equipment[ v ] = option
        end

        self.NewItemInfo = false
    end


    local ToggleCount = {}
    local tAbilities = {}
    local tItems = {}


    local function BuildToggleList( options, specID, section, useName, description, extraOptions )
        local db = options.args.toggles.plugins[ section ]
        local e

        local function tlEntry( key )
            if db[ key ] then
                v.hidden = nil
                return db[ key ]
            end
            db[ key ] = {}
            return db[ key ]
        end

        if db then
            for k, v in pairs( db ) do
                v.hidden = true
            end
        else
            db = {}
        end

        local nToggles = ToggleCount[ specID ] or 0
        nToggles = nToggles + 1

        local hider = function()
            return not config.expanded[ section ]
        end

        local settings = Hekili.DB.profile.specs[ specID ]

        wipe( tAbilities )
        for k, v in pairs( class.abilityList ) do
            local a = class.abilities[ k ]
            if a and a.id and ( a.id > 0 or a.id < -100 ) and a.id ~= 61304 and not a.item then
                if settings.abilities[ k ].toggle == section or a.toggle == section and settings.abilities[ k ].toggle == 'default' then
                    tAbilities[ k ] = class.abilityList[ k ] or v
                end
            end
        end

        e = tlEntry( section .. "Spacer" )
        e.type = "description"
        e.name = ""
        e.order = nToggles
        e.width = "full"

        e = tlEntry( section .. "Expander" )
        e.type = "execute"
        e.name = ""
        e.order = nToggles + 0.01
        e.width = 0.15
        e.image = function ()
            if not config.expanded[ section ] then return "Interface\\AddOns\\Hekili\\Textures\\WhiteRight" end
            return "Interface\\AddOns\\Hekili\\Textures\\WhiteDown"
        end
        e.imageWidth = 20
        e.imageHeight = 20
        e.func = function( info )
            config.expanded[ section ] = not config.expanded[ section ]
        end

        if type( useName ) == "function" then
            useName = useName()
        end

        e = tlEntry( section .. "Label" )
        e.type = "description"
        e.name = useName or section
        e.order = nToggles + 0.02
        e.width = 2.85
        e.fontSize = "large"

        if description then
            e = tlEntry( section .. "Description" )
            e.type = "description"
            e.name = description
            e.order = nToggles + 0.05
            e.width = "full"
            e.hidden = hider
        else
            if db[ section .. "Description" ] then db[ section .. "Description" ].hidden = true end
        end

        local count, offset = 0, 0

        for ability, isMember in orderedPairs( tAbilities ) do
            if isMember then
                if count % 2 == 0 then
                    e = tlEntry( section .. "LB" .. count )
                    e.type = "description"
                    e.name = ""
                    e.order = nToggles + 0.1 + offset
                    e.width = "full"
                    e.hidden = hider

                    offset = offset + 0.001
                end

                e = tlEntry( section .. "Remove" .. ability )
                e.type = "execute"
                e.name = ""
                e.desc = function ()
                    local a = class.abilities[ ability ]
                    local desc
                    if a then
                        if a.item then desc = a.link or a.name
                        else desc = class.abilityList[ a.key ] or a.name end
                    end
                    desc = desc or ability

                    return "移除 " .. desc .. "，從 " .. ( useName or section ) .. " 切換。"
                end
                e.image = RedX
                e.imageHeight = 16
                e.imageWidth = 16
                e.order = nToggles + 0.1 + offset
                e.width = 0.15
                e.func = function ()
                    settings.abilities[ ability ].toggle = 'none'
                    -- e.hidden = true
                    Hekili:EmbedSpecOptions()
                end
                e.hidden = hider

                offset = offset + 0.001


                e = tlEntry( section .. ability .. "Name" )
                e.type = "description"
                e.name = function ()
                    local a = class.abilities[ ability ]
                    if a then
                        if a.item then return a.link or a.name end
                        return class.abilityList[ a.key ] or a.name
                    end
                    return ability
                end
                e.order = nToggles + 0.1 + offset
                e.fontSize = "medium"
                e.width = 1.35
                e.hidden = hider

                offset = offset + 0.001

                --[[ e = tlEntry( section .. "Toggle" .. ability )
                e.type = "toggle"
                e.icon = RedX
                e.name = function ()
                    local a = class.abilities[ ability ]
                    if a then
                        if a.item then return a.link or a.name end
                        return a.name
                    end
                    return ability
                end
                e.desc = "Remove this from " .. ( useName or section ) .. "?"
                e.order = nToggles + 0.1 + offset
                e.width = 1.5
                e.hidden = hider
                e.get = function() return true end
                e.set = function()
                    settings.abilities[ ability ].toggle = 'none'
                    Hekili:EmbedSpecOptions()
                end

                offset = offset + 0.001 ]]

                count = count + 1
            end
        end


        e = tlEntry( section .. "FinalLB" )
        e.type = "description"
        e.name = ""
        e.order = nToggles + 0.993
        e.width = "full"
        e.hidden = hider

        e = tlEntry( section .. "AddBtn" )
        e.type = "execute"
        e.name = ""
        e.image = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus"
        e.imageHeight = 16
        e.imageWidth = 16
        e.order = nToggles + 0.995
        e.width = 0.15
        e.func = function ()
            config.adding[ section ]  = true
        end
        e.hidden = hider


        e = tlEntry( section .. "AddText" )
        e.type = "description"
        e.name = "加入技能"
        e.fontSize = "medium"
        e.width = 1.35
        e.order = nToggles + 0.996
        e.hidden = function ()
            return hider() or config.adding[ section ]
        end


        e = tlEntry( section .. "Add" )
        e.type = "select"
        e.name = ""
        e.values = function()
            local list = {}

            for k, v in pairs( class.abilityList ) do
                local a = class.abilities[ k ]
                if a and ( a.id > 0 or a.id < -100 ) and a.id ~= 61304 and not a.item then
                    if settings.abilities[ k ].toggle == 'default' or settings.abilities[ k ].toggle == 'none' then
                        list[ k ] = class.abilityList[ k ] or v
                    end
                end
            end

            return list
        end
        e.sorting = function()
            local list = {}

            for k, v in pairs( class.abilityList ) do
                insert( list, {
                    k, class.abilities[ k ].name or v or k
                } )
            end

            sort( list, function( a, b ) return a[2] < b[2] end )

            for i = 1, #list do
                list[ i ] = list[ i ][ 1 ]
            end

            return list
        end
        e.order = nToggles + 0.997
        e.width = 1.35
        e.get = function () end
        e.set = function ( info, val )
            local a = class.abilities[ val ]
            if a then
                settings[ a.item and "items" or "abilities" ][ val ].toggle = section
                config.adding[ section ] = false
                Hekili:EmbedSpecOptions()
            end
        end
        e.hidden = function ()
            return hider() or not config.adding[ section ]
        end


        e = tlEntry( section .. "Reload" )
        e.type = "execute"
        e.name = ""
        e.order = nToggles + 0.998
        e.width = 0.15
        e.image = GetAtlasFile( "transmog-icon-revert" )
        e.imageCoords = GetAtlasCoords( "transmog-icon-revert" )
        e.imageWidth = 16
        e.imageHeight = 16
        e.func = function ()
            for k, v in pairs( settings.abilities ) do
                local a = class.abilities[ k ]
                if a and not a.item and v.toggle == section or ( class.abilities[ k ].toggle == section ) then v.toggle = 'default' end
            end
            for k, v in pairs( settings.items ) do
                local a = class.abilities[ k ]
                if a and a.item and v.toggle == section or ( class.abilities[ k ].toggle == section ) then v.toggle = 'default' end
            end
            Hekili:EmbedSpecOptions()
        end
        e.hidden = hider


        e = tlEntry( section .. "ReloadText" )
        e.type = "description"
        e.name = "重新載入預設值"
        e.fontSize = "medium"
        e.order = nToggles + 0.999
        e.width = 1.35
        e.hidden = hider


        if extraOptions then
            for k, v in pairs( extraOptions ) do
                e = tlEntry( section .. k )
                e.type = v.type or "description"
                e.name = v.name or ""
                e.desc = v.desc or ""
                e.order = v.order or ( nToggles + 1 )
                e.width = v.width or 1.35
                e.hidden = v.hidden or hider
                e.get = v.get
                e.set = v.set
                for opt, val in pairs( v ) do
                    if e[ opt ] == nil then
                        e[ opt ] = val
                    end
                end
            end
        end

        ToggleCount[ specID ] = nToggles
        options.args.toggles.plugins[ section ] = db
    end


    -- Options table constructors.
    function Hekili:EmbedSpecOptions( db )
        db = db or self.Options
        if not db then return end

        local i = 1

        while( true ) do
            local id, name, description, texture, role = GetSpecializationInfo( i )

            if not id then break end
            if description then description = description:match( "^(.-)\n" ) end

            local spec = class.specs[ id ]

            if spec then
                local sName = lower( name )
                specNameByID[ id ] = sName
                specIDByName[ sName ] = id

                specs[ id ] = Hekili:ZoomedTextureWithText( texture, name )

                local options = {
                    type = "group",
                    -- name = specs[ id ],
                    name = name,
                    icon = texture,
                    iconCoords = { 0.15, 0.85, 0.15, 0.85 },
                    desc = description,
                    order = 50 + i,
                    childGroups = "tab",
                    get = "GetSpecOption",
                    set = "SetSpecOption",

                    args = {
						core = {
							type = "group",
							name = "核心",
							desc = "核心功能和" .. specs[ id ] .. "專精的選項。",
							order = 1,
							args = {
								enabled = {
									type = "toggle",
									name = "啟用",
									desc = "勾選時，插件將會根據選定的優先順序列表為 " .. name .. " 提供優先順序建議。",
									order = 0,
									width = "full",
								},


								--[[ packInfo = {
									type = 'group',
									name = "",
									inline = true,
									order = 1,
									args = {

									}
								}, ]]

								package = {
									type = "select",
									name = "優先順序",
									desc = "插件在提出優先順序建議時將會使用選定的動作包。",
									order = 1,
									width = 2.85,
									values = function( info, val )
										wipe( packs )

										for key, pkg in pairs( self.DB.profile.packs ) do
											local pname = pkg.builtIn and "|cFF00B4FF" .. key .. "|r" or key
											if pkg.spec == id then
												packs[ key ] = Hekili:ZoomedTextureWithText( texture, pname )
											end
										end

										packs[ '(none)' ] = '(none)'

										return packs
									end,
								},

								openPackage = {
									type = 'execute',
									name = "",
									desc = "打開並查看此優先順序動作包及其動作列表。",
									image = GetAtlasFile( "communities-icon-searchmagnifyingglass" ),
									imageCoords = GetAtlasCoords( "communities-icon-searchmagnifyingglass" ),
									imageHeight = 24,
									imageWidth = 24,
									disabled = function( info, val )
										local pack = self.DB.profile.specs[ id ].package
										return rawget( self.DB.profile.packs, pack ) == nil
									end,
									func = function ()
										ACD:SelectGroup( "Hekili", "packs", self.DB.profile.specs[ id ].package )
									end,
									order = 1.1,
									width = 0.15,
								},

								blankLine1 = {
									type = 'description',
									name = '',
									order = 1.2,
									width = 'full'
								},
							},
							plugins = {
								settings = {}
							},
						},

						targets = {
							type = "group",
							name = "目標",
							desc = "與如何識別敵人和計算敵人數量相關的設定。",
							order = 3,
							args = {
								targetsHeader = {
									type = "description",
									name = "這些設定控制產生技能建議時如何計算目標數量。\n\n預設情況下，目標數量"
										.. "會顯示在主要和多目標技能組中主圖示的右下角，除非只偵測到單一目標。\n\n",
									width = "full",
									order = 0.01
								},
								yourTarget = {
									type = "toggle",
									name = "你的目標",
									desc = "你的實際目標始終會被以敵人來計算，即使你沒有目標。\n\n"
										.. "此設定無法停用。",
									width = "full",
									get = function() return true end,
									set = function() end,
									order = 0.02,
								},

								-- 傷害檢測準群組
								damage = {
									type = "toggle",
									name = "計算受傷的敵人",
									desc = "勾選時，你已造成傷害的目標將會在幾秒鐘內被計算為有效敵人，將它們與你尚未攻擊的其他敵人區分開來。\n\n"
										.. CreateAtlasMarkup( "services-checkmark" ) .. " 在名條停用時自動啟用\n\n"
										.. CreateAtlasMarkup( "services-checkmark" ) .. " 建議用於|cffffd100遠程|r無法使用|cffffd100基於寵物目標的偵測方式|r",
									width = "full",
									order = 0.3,
								},

								dmgGroup = {
									type = "group",
									inline = true,
									name = "傷害偵測",
									order = 0.4,
									hidden = function () return self.DB.profile.specs[ id ].damage == false end,
									args = {
										damagePets = {
											type = "toggle",
											name = "被僕從傷害的敵人",
											desc = "勾選時，插件將會計算在過去幾秒鐘內你的寵物或僕從擊中 (或擊中你) 的敵人。  "
												.. "如果你的寵物/僕從分散在戰場上，可能會導致目標計數錯誤。",
											order = 1,
											width = "full",
										},

										damageExpiration = {
											type = "range",
											name = "超時",
											desc = "敵人將會被計數，直到它們被忽略/未受傷超過這段時間 (或它們死亡)。\n\n"
												.. "理想情況下，此時間區段應反映足夠的時間，以便在此時間區段內繼續對敵人造成 AOE/劈砍傷害，但不要太長，以至於敵人"
												.. "可能會離開範圍。",
											softMin = 3,
											min = 1,
											max = 10,
											step = 0.1,
											order = 2,
											width = "full",
										},

										damageDots = {
											type = "toggle",
											name = "帶有 DOT / 減益的敵人",
											desc = "勾選時，帶有你的減益或持續傷害效果的敵人將會被計算為目標，無論它們在戰場上的位置如何。\n\n"
												.. "這對於近戰專精可能不理想，因為敵人在你施加 DOT/出血後可能會走開。如果已啟用|cFFFFD100計算名條|r，"
												.. "則不再在範圍內的敵人將會被過濾掉。\n\n"
												.. "建議用於會對多個敵人施加 DOT 並且不依賴於敵人聚集以造成 AOE 傷害的遠程專精。",
											width = "full",
											order = 3,
										},

										damageOnScreen = {
											type = "toggle",
											name = "過濾畫面外 (看不到名條) 的敵人",
											desc = function()
												return "勾選時，基於傷害的目標系統將只計算畫面上的敵人。如未勾選，畫面外的目標可以包含在目標計數中。\n\n"
													.. ( GetCVar( "nameplateShowEnemies" ) == "0" and "|cFFFF0000需要顯示敵方名條|r" or "|cFF00FF00需要顯示敵方名條|r" )
											end,
											width = "full",
											order = 4,
										},
									},
								},
								nameplates = {
									type = "toggle",
									name = "計算名條",
									desc = "勾選時，指定半徑內的敵方名條將會被計算為敵方目標。\n\n"
										.. AtlasToString( "common-icon-checkmark" ) .. " 建議用於使用 10 碼或更短範圍的近戰專精\n\n"
										.. AtlasToString( "common-icon-redx" ) .. " 不建議用於遠程專精。",
									width = "full",
									order = 0.1,
								},

								npGroup = {
									type = "group",
									inline = true,
									name = "名條偵測",
									order = 0.2,
									hidden = function ()
										return not self.DB.profile.specs[ id ].nameplates
									end,
									args = {
										nameplateRequirements = {
											type = "description",
											name = "此功能要求同時啟用 |cFFFFD100顯示敵方名條|r 和 |cFFFFD100顯示所有名條|r。",
											width = "full",
											hidden = function()
												return GetCVar( "nameplateShowEnemies" ) == "1" and GetCVar( "nameplateShowAll" ) == "1"
											end,
											order = 1,
										},

										nameplateShowEnemies = {
											type = "toggle",
											name = "顯示敵方名條",
											desc = "勾選時，將會顯示敵方名條，並可以用於計算敵方目標數量。",
											width = 1.4,
											get = function()
												return GetCVar( "nameplateShowEnemies" ) == "1"
											end,
											set = function( info, val )
												if InCombatLockdown() then return end
												SetCVar( "nameplateShowEnemies", val and "1" or "0" )
											end,
											hidden = function()
												return GetCVar( "nameplateShowEnemies" ) == "1" and GetCVar( "nameplateShowAll" ) == "1"
											end,
											order = 1.2,
										},

										nameplateShowAll = {
											type = "toggle",
											name = "顯示所有名條",
											desc = "勾選時，將會顯示所有敵方名條 (而不僅僅是你的目標)，並可以用於計算敵方目標數量。",
											width = 1.4,
											get = function()
												return GetCVar( "nameplateShowAll" ) == "1"
											end,
											set = function( info, val )
												if InCombatLockdown() then return end
												SetCVar( "nameplateShowAll", val and "1" or "0" )
											end,
											hidden = function()
												return GetCVar( "nameplateShowEnemies" ) == "1" and GetCVar( "nameplateShowAll" ) == "1"
											end,
											order = 1.3,
										},

										--[[ rangeFilter = {
											type = "toggle",
											name = function()
												if spec.filterName then return format( "使用自動過濾：  %s", spec.filterName ) end
												return "使用自動過濾"
											end,
											desc = function()
												return format( "當此選項可用時，可以使用推薦的過濾方式，將名條偵測半徑限制為適合你專精的合理"
												.. "範圍。強烈建議大多數玩家使用此功能。\n\n如果未啟用此過方式，則必須改用|cffffd100依法術過濾範圍|r "
												.. "。\n\n過濾方式： %s", spec.filterName or "" )
											end,
											hidden = function() return not spec.filterName end,
											order = 1.6,
											width = "full"
										}, ]]

										nameplateRange = {
											type = "range",
											name = "敵人範圍半徑",
											desc = "如果啟用 |cFFFFD100計算名條|r，則此範圍內的敵人將會包含在目標計數中。\n\n"
												.. "只有在同時啟用 |cFFFFD100顯示敵方名條|r 和 |cFFFFD100顯示所有名條|r 時，此設定才可用。",
											width = "full",
											order = 1.7,
											min = 0,
											max = 100,
											step = 1,
											hidden = function()
												return not ( GetCVar( "nameplateShowEnemies" ) == "1" and GetCVar( "nameplateShowAll" ) == "1" )
											end,
										},

										--[[ rangeChecker = {
											type = "select",
											name = "依法術過濾範圍",
											desc = "啟用 |cFFFFD100計算名條|r 時，此技能範圍內的敵人將會包含在目標計數中。\n\n"
											.. "你的角色必須實際知道所選的法術，否則將會強制啟用 |cFFFFD100依傷害計算目標|r。",
											width = "full",
											order = 1.8,
											values = function( info )
												local ranges = class.specs[ id ].ranges
												local list = {}

												for _, spell in pairs( ranges ) do
													local output
													local ability = class.abilities[ spell ]

													if ability and ability.id > 0 then
														local minR, maxR = select( 5, GetSpellInfo( ability.id ) )

														if maxR == 0 then
															output = format( "%s (近戰)", Hekili:GetSpellLinkWithTexture( ability.id ) )
														elseif minR > 0 then
															output = format( "%s (%d - %d 碼)", Hekili:GetSpellLinkWithTexture( ability.id ), minR, maxR )
														else
															output = format( "%s (%d 碼)", Hekili:GetSpellLinkWithTexture( ability.id ), maxR )
														end

														list[ spell ] = output
													end
												end
												return list
											end,
											get = function()
												-- 如果它是空白的，默認選擇第一個選項。
												if spec.ranges and not self.DB.profile.specs[ id ].rangeChecker then
													self.DB.profile.specs[ id ].rangeChecker = spec.ranges[ 1 ]
												else
													local found = false
													for k, v in pairs( spec.ranges ) do
														if v == self.DB.profile.specs[ id ].rangeChecker then
															found = true
															break
														end
													end

													if not found then
														self.DB.profile.specs[ id ].rangeChecker = spec.ranges[ 1 ]
													end
												end

												return self.DB.profile.specs[ id ].rangeChecker
											end,
											disabled = function()
												return self.DB.profile.specs[ id ].rangeFilter
											end,
											hidden = function()
												return self.DB.profile.specs[ id ].nameplates == false
											end,
										}, ]]

										-- 基於寵物的集群檢測
										petbased = {
											type = "toggle",
											name = "計算你寵物附近的目標",
											desc = function ()
												local msg = "勾選並正確設定時，當你的目標也在你的寵物範圍內時，插件將會將你寵物附近的目標計算為有效目標。"

												if Hekili:HasPetBasedTargetSpell() then
													local spell = Hekili:GetPetBasedTargetSpell()
													local link = Hekili:GetSpellLinkWithTexture( spell )

													msg = msg .. "\n\n" .. link .. "|w|r 在你的快捷列上，將會用於你所有的" .. UnitClass( "player" ) .. "寵物。"
												else
													msg = msg .. "\n\n|cFFFF0000需要寵物技能在你的其中一個快捷列上。|r"
												end

												if GetCVar( "nameplateShowEnemies" ) == "1" then
													msg = msg .. "\n\n敵方名條已|cFF00FF00啟用|r，將會用於偵測你寵物附近的目標。"
												else
													msg = msg .. "\n\n|cFFFF0000需要顯示敵方名條。|r"
												end

												return msg
											end,
											width = "full",
											hidden = function ()
												return Hekili:GetPetBasedTargetSpells() == nil
											end,
											order = 3.1
										},

										petbasedGuidance = {
											type = "description",
											name = function ()
												local out

												if not self:HasPetBasedTargetSpell() then
													out = "為了使基於寵物的偵測正常工作，必須從你的|cFF00FF00寵物法術書|r中選擇一個技能，並將其放置在|cFF00FF00你的|r 其中一個快捷列上。\n\n"
													local spells = Hekili:GetPetBasedTargetSpells()

													if not spells then return " " end

													out = out .. "對於 %s，由於其範圍，建議使用 %s。它將會適用於你所有的寵物。"

													if spells.count > 1 then
														out = out .. "\n替代方案: "
													end

													local n = 1

													local link = Hekili:GetSpellLinkWithTexture( spells.best )
													out = format( out, UnitClass( "player" ), link )
													for spell in pairs( spells ) do
														if type( spell ) == "number" and spell ~= spells.best then
															n = n + 1

															link = Hekili:GetSpellLinkWithTexture( spell )

															if n == 2 and spells.count == 2 then
																out = out .. link .. "。"
															elseif n ~= spells.count then
																out = out .. link .. "，"
															else
																out = out .. "和 " .. link .. "。"
															end
														end
													end
												end

												if GetCVar( "nameplateShowEnemies" ) ~= "1" then
													if not out then
														out = "|cFFFF0000警告！|r基於寵物的目標偵測需要啟用|cFFFFD100敵方名條|r。"
													else
														out = out .. "\n\n|cFFFF0000警告！|r基於寵物的目標偵測需要啟用|cFFFFD100敵方名條|r。"
													end
												end

												return out
											end,
											fontSize = "medium",
											width = "full",
											disabled = function ( info, val )
												if Hekili:GetPetBasedTargetSpells() == nil then return true end
												if self.DB.profile.specs[ id ].petbased == false then return true end
												if self:HasPetBasedTargetSpell() and GetCVar( "nameplateShowEnemies" ) == "1" then return true end

												return false
											end,
											order = 3.11,
										}
									}
								},

								--[[ nameplateRange = {
									type = "range",
									name = "Nameplate Detection Range",
									desc = "When |cFFFFD100Use Nameplate Detection|r is checked, the addon will count any enemies with visible nameplates within this radius of your character.",
									width = "full",
									hidden = function()
										return self.DB.profile.specs[ id ].nameplates == false
									end,
									min = 0,
									max = 100,
									step = 1,
									order = 2,
								}, ]]

								cycle = {
									type = "toggle",
									name = "建議更改目標 |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t",
									desc = "啟用目標切換時，可能會顯示一個圖示（|TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t），表示你應該在其他目標上使用技能。\n\n" ..
										"這對於一些只想將減益效果施加到另一個目標的專精 (例如御風武僧) 來說效果很好，但對於關注" ..
										"基於持續時間維護 DOT/減益效果的專精（例如痛苦術士）來說效果可能較差。\n\n此功能將在未來的更新中進行改進。",
									width = "full",
									order = 6
								},

								cycleGroup = {
									type = "group",
									name = "次要目標",
									inline = true,
									hidden = function() return not self.DB.profile.specs[ id ].cycle end,
									order = 7,
									args = {
										cycle_min = {
											type = "range",
											name = "依死亡時間過濾",
											desc = "勾選 |cffffd100建議目標切換|r 時，此值決定哪些目標會被計入目標切換目的。如果設定為 5，如果沒有其他目標可以存活 5 秒或更長時間，則不會建議目標切換。  " ..
													"這可以避免將持續傷害效果施加到一個會太快死亡而無法受到傷害的目標。\n\n設定為 0 以計數所有偵測到的目標。",
											width = "full",
											min = 0,
											max = 15,
											step = 1,
											order = 1
										},
									}
								},

								aoe = {
									type = "range",
									name = "多目標技能組: 最小目標數",
									desc = "顯示多目標技能組 (或主要技能組處於多目標模式) 時，其建議將會假設至少有這麼多目標可用。",
									width = "full",
									min = 2,
									max = 10,
									step = 1,
									order = 10,
								},
							}
						},

						--[[ toggles = {
							type = "group",
							name = "Toggles",
							desc = "Specify which abilities are controlled by each toggle keybind for this specialization.",
							order = 2,
							args = {
								toggleDesc = {
									type = "description",
									name = "This section shows which Abilities are enabled/disabled when you toggle each category when in this specialization.  Gear and Items can be adjusted via their own section (left).\n\n" ..
										"Removing an ability from its toggle leaves it |cFF00FF00ENABLED|r regardless of whether the toggle is active.",
									fontSize = "medium",
									order = 1,
									width = "full",
								},
							},
							plugins = {
								cooldowns = {},
								essences = {},
								defensives = {},
								utility = {},
								custom1 = {},
								custom2 = {},
							}
						}, ]]

						performance = {
							type = "group",
							name = "效能",
							order = 10,
							args = {
								throttleRefresh = {
									type = "toggle",
									name = "設定更新週期",
									desc = "勾選時，可以指定新建議生成的頻率，包括戰鬥中和非戰鬥中。\n\n"
										.. "更頻繁的更新可能會使用更多的 CPU 時間，但會增加回應速度。在某些關鍵的戰鬥"
										.. "事件之後，將會永遠提早更新建議，無視這些設定。",
									order = 1,
									width = "full",
								},

								regularRefresh = {
									type = "range",
									name = "非戰鬥中週期",
									desc = "在非戰鬥中，每個技能組會按照指定的頻率更新其建議。 "
										.. "指定較低的數字意味著更頻繁地生成更新，可能會使用更多的 CPU 時間。\n\n"
										.. "某些關鍵事件，例如生成資源，將會強制更新提早發生，無視此設定。\n\n"
										.. "預設值: |cffffd1000.5|r 秒。",
									order = 1.1,
									width = 1.5,
									min = 0.05,
									max = 1,
									step = 0.05,
									hidden = function () return self.DB.profile.specs[ id ].throttleRefresh == false end,
								},

								combatRefresh = {
									type = "range",
									name = "戰鬥中週期",
									desc = "在戰鬥中，每個技能組會按照指定的頻率更新其建議。\n\n"
									.. "指定較低的數字意味著更頻繁地生成更新，可能會使用更多的 CPU 時間。\n\n"
									.. "某些關鍵事件，例如生成資源，將會強制更新提早發生，無視此設定。\n\n"
									.. "預設值: |cffffd1000.25|r 秒。",
									order = 1.2,
									width = 1.5,
									min = 0.05,
									max = 0.5,
									step = 0.05,
									hidden = function () return self.DB.profile.specs[ id ].throttleRefresh == false end,
								},

								throttleTime = {
									type = "toggle",
									name = "設定更新時間",
									desc = "預設情況下，計算會佔用 80% 的畫面時間或 50 毫秒，以較低者為準。如果建議花費的"
										.. "時間超過分配的時間，則工作將會分佈在多個畫面中，以減少對畫面更新率的影響。\n\n"
										.. "如果你選擇 |cffffd100設定更新時間|r，則可以指定每個畫面使用的 |cffffd100最大更新時間|r。",
									order = 2.1,
									width = "full",
								},

								maxTime = {
									type = "range",
									name = "最大更新時間 (毫秒)",
									desc = "指定更新時|cffffd100每個畫面|r可以使用的最大時間 (以毫秒為單位)。  " ..
										"如果設定為 |cffffd1000|r，則無論你的畫面更新率如何，都沒有最大值。\n\n" ..
										"|cffffd100範例|r\n" ..
										"|W- 60 FPS:1 秒 / 60 畫面 = |cffffd10016.7|r 毫秒|w\n" ..
										"|W- 100 FPS:1 秒 / 100 畫面 = |cffffd10010|r 毫秒|w\n\n" ..
										"如果將此值設定得太低，則更新可能需要更長的時間，並且可能會感覺回應速度較慢。\n\n" ..
										"如果設定得太高 (或設定為零)，更新可能會更快地解決，但可能會影響你的 FPS。\n\n" ..
										"預設值為 |cffffd10020|r 毫秒。",
									order = 2.2,
									min = 0,
									max = 100,
									step = 1,
									width = 1.5,
									hidden = function ()
										return not self.DB.profile.specs[ id ].throttleTime
									end,
								},

								--[[ gcdSync = {
									type = "toggle",
									name = "Start after Global Cooldown",
									desc = "If checked, the addon's first recommendation will be delayed to the start of the GCD in your Primary and AOE displays.  This can reduce flickering if trinkets or off-GCD abilities are appearing briefly during the global cooldown, " ..
										"but will cause abilities intended to be used while the GCD is active (i.e., Recklessness) to bounce backward in the queue.",
									width = "full",
									order = 4,
								}, ]]

								--[[ enhancedRecheck = {
									type = "toggle",
									name = "Enhanced Recheck",
									desc = "When the addon cannot recommend an ability at the present time, it rechecks action conditions at a few points in the future.  "
										.. "If checked, this feature will enable the addon to do additional checking on entries that use the 'variable' feature.  "
										.. "This may use slightly more CPU, but can reduce the likelihood that the addon will fail to make a recommendation.",
									width = "full",
									order = 5,
								}, ]]
							}
						}
					},
				}

                local specCfg = class.specs[ id ] and class.specs[ id ].settings
                local specProf = self.DB.profile.specs[ id ]

                if #specCfg > 0 then
                    options.args.core.plugins.settings.prefSpacer = {
                        type = "description",
                        name = " ",
                        order = 100,
                        width = "full"
                    }

                    options.args.core.plugins.settings.prefHeader = {
                        type = "header",
                        name = "Preferences",
                        order = 100.1,
                    }

                    for i, option in ipairs( specCfg ) do
                        if i > 1 and i % 2 == 1 then
                            -- Insert line break.
                            options.args.core.plugins.settings[ sName .. "LB" .. i ] = {
                                type = "description",
                                name = "",
                                width = "full",
                                order = option.info.order - 0.01
                            }
                        end

                        options.args.core.plugins.settings[ option.name ] = option.info
                        if self.DB.profile.specs[ id ].settings[ option.name ] == nil then
                            self.DB.profile.specs[ id ].settings[ option.name ] = option.default
                        end
                    end
                end

                -- Toggles
                --[[ BuildToggleList( options, id, "cooldowns",  "Cooldowns" )
                BuildToggleList( options, id, "essences",   "Minor CDs" )
                BuildToggleList( options, id, "interrupts", "Utility / Interrupts" )
                BuildToggleList( options, id, "defensives", "Defensives",   "The defensive toggle is generally intended for tanking specializations, " ..
                                                                            "as you may want to turn on/off recommendations for damage mitigation abilities " ..
                                                                            "for any number of reasons during a fight.  DPS players may want to add their own " ..
                                                                            "defensive abilities, but would also need to add the abilities to their own custom " ..
                                                                            "priority packs." )
                BuildToggleList( options, id, "custom1", function ()
                    return specProf.custom1Name or "Custom 1"
                end )
                BuildToggleList( options, id, "custom2", function ()
                    return specProf.custom2Name or "Custom 2"
                end ) ]]

                db.plugins.specializations[ sName ] = options
            end

            i = i + 1
        end

    end


    local packControl = {
        listName = "default",
        actionID = "0001",

        makingNew = false,
        newListName = nil,

        showModifiers = false,

        newPackName = "",
        newPackSpec = "",
    }


    local nameMap = {
        call_action_list = "list_name",
        run_action_list = "list_name",
        variable = "var_name",
        op = "op"
    }


    local defaultNames = {
        list_name = "default",
        var_name = "unnamed_var",
    }


    local toggleToNumber = {
        cycle_targets = true,
        for_next = true,
        max_energy = true,
        only_cwc = true,
        strict = true,
        use_off_gcd = true,
        use_while_casting = true
    }


    local function GetListEntry( pack )
        local entry = rawget( Hekili.DB.profile.packs, pack )

        if rawget( entry.lists, packControl.listName ) == nil then
            packControl.listName = "default"
        end

        if entry then entry = entry.lists[ packControl.listName ] else return end

        if rawget( entry, tonumber( packControl.actionID ) ) == nil then
            packControl.actionID = "0001"
        end

        local listPos = tonumber( packControl.actionID )
        if entry and listPos > 0 then entry = entry[ listPos ] else return end

        return entry
    end


    function Hekili:GetActionOption( info )
        local n = #info
        local pack, option = info[ 2 ], info[ n ]

        if rawget( self.DB.profile.packs[ pack ].lists, packControl.listName ) == nil then
            packControl.listName = "default"
        end

        local actionID = tonumber( packControl.actionID )
        local data = self.DB.profile.packs[ pack ].lists[ packControl.listName ]

        if option == 'position' then return actionID
        elseif option == 'newListName' then return packControl.newListName end

        if not data then return end

        if not data[ actionID ] then
            actionID = 1
            packControl.actionID = "0001"
        end
        data = data[ actionID ]

        if option == "inputName" or option == "selectName" then
            option = nameMap[ data.action ]
            if not data[ option ] then data[ option ] = defaultNames[ option ] end
        end

        if option == "op" and not data.op then return "set" end

        if option == "potion" then
            if not data.potion then return "default" end
            if not class.potionList[ data.potion ] then
                return class.potions[ data.potion ] and class.potions[ data.potion ].key or data.potion
            end
        end

        if toggleToNumber[ option ] then return data[ option ] == 1 end
        return data[ option ]
    end


    function Hekili:SetActionOption( info, val )
        local n = #info
        local pack, option = info[ 2 ], info[ n ]

        local actionID = tonumber( packControl.actionID )
        local data = self.DB.profile.packs[ pack ].lists[ packControl.listName ]

        if option == 'newListName' then
            packControl.newListName = val:trim()
            return
        end

        if not data then return end
        data = data[ actionID ]

        if option == "inputName" or option == "selectName" then option = nameMap[ data.action ] end

        if toggleToNumber[ option ] then val = val and 1 or 0 end
        if type( val ) == 'string' then val = val:trim() end

        data[ option ] = val

        if option == "enable_moving" and not val then
            data.moving = nil
        end

        if option == "line_cd" and not val then
            data.line_cd = nil
        end

        if option == "use_off_gcd" and not val then
            data.use_off_gcd = nil
        end

        if option =="only_cwc" and not val then
            data.only_cwc = nil
        end

        if option == "strict" and not val then
            data.strict = nil
        end

        if option == "use_while_casting" and not val then
            data.use_while_casting = nil
        end

        if option == "action" then
            self:LoadScripts()
        else
            self:LoadScript( pack, packControl.listName, actionID )
        end

        if option == "enabled" then
            Hekili:UpdateDisplayVisibility()
        end
    end


    function Hekili:GetPackOption( info )
        local n = #info
        local category, subcat, option = info[ 2 ], info[ 3 ], info[ n ]

        if rawget( self.DB.profile.packs, category ) and rawget( self.DB.profile.packs[ category ].lists, packControl.listName ) == nil then
            packControl.listName = "default"
        end

        if option == "newPackSpec" and packControl[ option ] == "" then
            packControl[ option ] = GetCurrentSpec()
        end

        if packControl[ option ] ~= nil then return packControl[ option ] end

        if subcat == 'lists' then return self:GetActionOption( info ) end

        local data = rawget( self.DB.profile.packs, category )
        if not data then return end

        if option == 'date' then return tostring( data.date ) end

        return data[ option ]
    end


    function Hekili:SetPackOption( info, val )
        local n = #info
        local category, subcat, option = info[ 2 ], info[ 3 ], info[ n ]

        if packControl[ option ] ~= nil then
            packControl[ option ] = val
            if option == "listName" then packControl.actionID = "0001" end
            return
        end

        if subcat == 'lists' then return self:SetActionOption( info, val ) end
        -- if subcat == 'newActionGroup' or ( subcat == 'actionGroup' and subtype == 'entry' ) then self:SetActionOption( info, val ); return end

        local data = rawget( self.DB.profile.packs, category )
        if not data then return end

        if type( val ) == 'string' then val = val:trim() end

        if option == "desc" then
            -- Auto-strip comments prefix
            val = val:gsub( "^#+ ", "" )
            val = val:gsub( "\n#+ ", "\n" )
        end

        data[ option ] = val
    end


    function Hekili:EmbedPackOptions( db )
        db = db or self.Options
        if not db then return end

        local packs = db.args.packs or {
            type = "group",
            name = "Priorities",
            desc = "Priorities (or action packs) are bundles of action lists used to make recommendations for each specialization.",
            get = 'GetPackOption',
            set = 'SetPackOption',
            order = 65,
            childGroups = 'tree',
            args = {
                packDesc = {
                    type = "description",
                    name = "Priorities (or action packs) are bundles of action lists used to make recommendations for each specialization.  " ..
                        "They can be customized and shared.  |cFFFF0000Imported SimulationCraft priorities often require some translation before " ..
                        "they will work with this addon.  No support is offered for customized or imported priorities.|r",
                    order = 1,
                    fontSize = "medium",
                },

                newPackHeader = {
                    type = "header",
                    name = "Create a New Priority",
                    order = 200
                },

                newPackName = {
                    type = "input",
                    name = "Priority Name",
                    desc = "Enter a new, unique name for this package.  Only alphanumeric characters, spaces, underscores, and apostrophes are allowed.",
                    order = 201,
                    width = "full",
                    validate = function( info, val )
                        val = val:trim()
                        if rawget( Hekili.DB.profile.packs, val ) then return "Please specify a unique pack name."
                        elseif val == "UseItems" then return "UseItems is a reserved name."
                        elseif val == "(none)" then return "Don't get smart, missy."
                        elseif val:find( "[^a-zA-Z0-9 _']" ) then return "Only alphanumeric characters, spaces, underscores, and apostrophes are allowed in pack names." end
                        return true
                    end,
                },

                newPackSpec = {
                    type = "select",
                    name = "Specialization",
                    order = 202,
                    width = "full",
                    values = specs,
                },

                createNewPack = {
                    type = "execute",
                    name = "Create New Pack",
                    order = 203,
                    disabled = function()
                        return packControl.newPackName == "" or packControl.newPackSpec == ""
                    end,
                    func = function ()
                        Hekili.DB.profile.packs[ packControl.newPackName ].spec = packControl.newPackSpec
                        Hekili:EmbedPackOptions()
                        ACD:SelectGroup( "Hekili", "packs", packControl.newPackName )
                        packControl.newPackName = ""
                        packControl.newPackSpec = ""
                    end,
                },

                shareHeader = {
                    type = "header",
                    name = "Sharing",
                    order = 100,
                },

                shareBtn = {
                    type = "execute",
                    name = "Share Priorities",
                    desc = "Each Priority can be shared with other addon users with these export strings.\n\n" ..
                        "You can also import a shared export string here.",
                    func = function ()
                        ACD:SelectGroup( "Hekili", "packs", "sharePacks" )
                    end,
                    order = 101,
                },

                sharePacks = {
                    type = "group",
                    name = "|cFF1EFF00Share Priorities|r",
                    desc = "Your Priorities can be shared with other addon users with these export strings.\n\n" ..
                        "You can also import a shared export string here.",
                    childGroups = "tab",
                    get = 'GetPackShareOption',
                    set = 'SetPackShareOption',
                    order = 1001,
                    args = {
                        import = {
                            type = "group",
                            name = "Import",
                            order = 1,
                            args = {
                                stage0 = {
                                    type = "group",
                                    name = "",
                                    inline = true,
                                    order = 1,
                                    args = {
                                        guide = {
                                            type = "description",
                                            name = "Paste a Priority import string here to begin.",
                                            order = 1,
                                            width = "full",
                                            fontSize = "medium",
                                        },

                                        separator = {
                                            type = "header",
                                            name = "Import String",
                                            order = 1.5,
                                        },

                                        importString = {
                                            type = "input",
                                            name = "Import String",
                                            get = function () return shareDB.import end,
                                            set = function( info, val )
                                                val = val:trim()
                                                shareDB.import = val
                                            end,
                                            order = 3,
                                            multiline = 5,
                                            width = "full",
                                        },

                                        btnSeparator = {
                                            type = "header",
                                            name = "Import",
                                            order = 4,
                                        },

                                        importBtn = {
                                            type = "execute",
                                            name = "Import Priority",
                                            order = 5,
                                            func = function ()
                                                shareDB.imported, shareDB.error = DeserializeActionPack( shareDB.import )

                                                if shareDB.error then
                                                    shareDB.import = "The Import String provided could not be decompressed.\n" .. shareDB.error
                                                    shareDB.error = nil
                                                    shareDB.imported = {}
                                                else
                                                    shareDB.importStage = 1
                                                end
                                            end,
                                            disabled = function ()
                                                return shareDB.import == ""
                                            end,
                                        },
                                    },
                                    hidden = function () return shareDB.importStage ~= 0 end,
                                },

                                stage1 = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 1,
                                    args = {
                                        packName = {
                                            type = "input",
                                            order = 1,
                                            name = "Pack Name",
                                            get = function () return shareDB.imported.name end,
                                            set = function ( info, val ) shareDB.imported.name = val:trim() end,
                                            width = "full",
                                        },

                                        packDate = {
                                            type = "input",
                                            order = 2,
                                            name = "Pack Date",
                                            get = function () return tostring( shareDB.imported.date ) end,
                                            set = function () end,
                                            width = "full",
                                            disabled = true,
                                        },

                                        packSpec = {
                                            type = "input",
                                            order = 3,
                                            name = "Pack Specialization",
                                            get = function () return select( 2, GetSpecializationInfoByID( shareDB.imported.payload.spec or 0 ) ) or "No Specialization Set" end,
                                            set = function () end,
                                            width = "full",
                                            disabled = true,
                                        },

                                        guide = {
                                            type = "description",
                                            name = function ()
                                                local listNames = {}

                                                for k, v in pairs( shareDB.imported.payload.lists ) do
                                                    insert( listNames, k )
                                                end

                                                table.sort( listNames )

                                                local o

                                                if #listNames == 0 then
                                                    o = "The imported Priority has no lists included."
                                                elseif #listNames == 1 then
                                                    o = "The imported Priority has one action list:  " .. listNames[1] .. "."
                                                elseif #listNames == 2 then
                                                    o = "The imported Priority has two action lists:  " .. listNames[1] .. " and " .. listNames[2] .. "."
                                                else
                                                    o = "The imported Priority has the following lists included:  "
                                                    for i, name in ipairs( listNames ) do
                                                        if i == 1 then o = o .. name
                                                        elseif i == #listNames then o = o .. ", and " .. name .. "."
                                                        else o = o .. ", " .. name end
                                                    end
                                                end

                                                return o
                                            end,
                                            order = 4,
                                            width = "full",
                                            fontSize = "medium",
                                        },

                                        separator = {
                                            type = "header",
                                            name = "Apply Changes",
                                            order = 10,
                                        },

                                        apply = {
                                            type = "execute",
                                            name = "Apply Changes",
                                            order = 11,
                                            confirm = function ()
                                                if rawget( self.DB.profile.packs, shareDB.imported.name ) then
                                                    return "You already have a \"" .. shareDB.imported.name .. "\" Priority.\nOverwrite it?"
                                                end
                                                return "Create a new Priority named \"" .. shareDB.imported.name .. "\" from the imported data?"
                                            end,
                                            func = function ()
                                                self.DB.profile.packs[ shareDB.imported.name ] = shareDB.imported.payload
                                                shareDB.imported.payload.date = shareDB.imported.date
                                                shareDB.imported.payload.version = shareDB.imported.date

                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 2

                                                self:LoadScripts()
                                                self:EmbedPackOptions()
                                            end,
                                        },

                                        reset = {
                                            type = "execute",
                                            name = "Reset",
                                            order = 12,
                                            func = function ()
                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 0
                                            end,
                                        },
                                    },
                                    hidden = function () return shareDB.importStage ~= 1 end,
                                },

                                stage2 = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    args = {
                                        note = {
                                            type = "description",
                                            name = "Imported settings were successfully applied!\n\nClick Reset to start over, if needed.",
                                            order = 1,
                                            fontSize = "medium",
                                            width = "full",
                                        },

                                        reset = {
                                            type = "execute",
                                            name = "Reset",
                                            order = 2,
                                            func = function ()
                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 0
                                            end,
                                        }
                                    },
                                    hidden = function () return shareDB.importStage ~= 2 end,
                                }
                            },
                            plugins = {
                            }
                        },

                        export = {
                            type = "group",
                            name = "Export",
                            order = 2,
                            args = {
                                guide = {
                                    type = "description",
                                    name = "Select a Priority pack to export.",
                                    order = 1,
                                    fontSize = "medium",
                                    width = "full",
                                },

                                actionPack = {
                                    type = "select",
                                    name = "Priorities",
                                    order = 2,
                                    values = function ()
                                        local v = {}

                                        for k, pack in pairs( Hekili.DB.profile.packs ) do
                                            if pack.spec and class.specs[ pack.spec ] then
                                                v[ k ] = k
                                            end
                                        end

                                        return v
                                    end,
                                    width = "full"
                                },

                                exportString = {
                                    type = "input",
                                    name = "Priority Export String",
                                    desc = "Press CTRL+A to select, then CTRL+C to copy.",
                                    order = 3,
                                    get = function ()
                                        if rawget( Hekili.DB.profile.packs, shareDB.actionPack ) then
                                            shareDB.export = SerializeActionPack( shareDB.actionPack )
                                        else
                                            shareDB.export = ""
                                        end
                                        return shareDB.export
                                    end,
                                    set = function () end,
                                    width = "full",
                                    hidden = function () return shareDB.export == "" end,
                                },
                            },
                        }
                    }
                },
            },
            plugins = {
                packages = {},
                links = {},
            }
        }

        wipe( packs.plugins.packages )
        wipe( packs.plugins.links )

        local count = 0

        for pack, data in orderedPairs( self.DB.profile.packs ) do
            if data.spec and class.specs[ data.spec ] and not data.hidden then
                packs.plugins.links.packButtons = packs.plugins.links.packButtons or {
                    type = "header",
                    name = "Installed Packs",
                    order = 10,
                }

                packs.plugins.links[ "btn" .. pack ] = {
                    type = "execute",
                    name = pack,
                    order = 11 + count,
                    func = function ()
                        ACD:SelectGroup( "Hekili", "packs", pack )
                    end,
                }

                local opts = packs.plugins.packages[ pack ] or {
                    type = "group",
                    name = function ()
                        local p = rawget( Hekili.DB.profile.packs, pack )
                        if p.builtIn then return '|cFF00B4FF' .. pack .. '|r' end
                        return pack
                    end,
                    icon = function()
                        return class.specs[ data.spec ].texture
                    end,
                    iconCoords = { 0.15, 0.85, 0.15, 0.85 },
                    childGroups = "tab",
                    order = 100 + count,
                    args = {
                        pack = {
                            type = "group",
                            name = data.builtIn and ( BlizzBlue .. "Summary|r" ) or "Summary",
                            order = 1,
                            args = {
                                isBuiltIn = {
                                    type = "description",
                                    name = function ()
                                        return BlizzBlue .. "This is a default priority package.  It will be automatically updated when the addon is updated.  If you want to customize this priority, " ..
                                            "make a copy by clicking |TInterface\\Addons\\Hekili\\Textures\\WhiteCopy:0|t.|r"
                                    end,
                                    fontSize = "medium",
                                    width = 3,
                                    order = 0.1,
                                    hidden = not data.builtIn
                                },

                                lb01 = {
                                    type = "description",
                                    name = "",
                                    order = 0.11,
                                    hidden = not data.builtIn
                                },

                                toggleActive = {
                                    type = "toggle",
                                    name = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        if p and p.builtIn then return BlizzBlue .. "Active|r" end
                                        return "Active"
                                    end,
                                    desc = "If checked, the addon's recommendations for this specialization are based on this priority package.",
                                    order = 0.2,
                                    width = 3,
                                    get = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return Hekili.DB.profile.specs[ p.spec ].package == pack
                                    end,
                                    set = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        if Hekili.DB.profile.specs[ p.spec ].package == pack then
                                            if p.builtIn then
                                                Hekili.DB.profile.specs[ p.spec ].package = "(none)"
                                            else
                                                for def, data in pairs( Hekili.DB.profile.packs ) do
                                                    if data.spec == p.spec and data.builtIn then
                                                        Hekili.DB.profile.specs[ p.spec ].package = def
                                                        return
                                                    end
                                                end
                                            end
                                        else
                                            Hekili.DB.profile.specs[ p.spec ].package = pack
                                        end
                                    end,
                                },

                                lb04 = {
                                    type = "description",
                                    name = "",
                                    order = 0.21,
                                    width = "full"
                                },

                                packName = {
                                    type = "input",
                                    name = "Priority Name",
                                    order = 0.25,
                                    width = 2.7,
                                    validate = function( info, val )
                                        val = val:trim()
                                        if rawget( Hekili.DB.profile.packs, val ) then return "Please specify a unique pack name."
                                        elseif val == "UseItems" then return "UseItems is a reserved name."
                                        elseif val == "(none)" then return "Don't get smart, missy."
                                        elseif val:find( "[^a-zA-Z0-9 _'()]" ) then return "Only alphanumeric characters, spaces, parentheses, underscores, and apostrophes are allowed in pack names." end
                                        return true
                                    end,
                                    get = function() return pack end,
                                    set = function( info, val )
                                        local profile = Hekili.DB.profile

                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        Hekili.DB.profile.packs[ pack ] = nil

                                        val = val:trim()
                                        Hekili.DB.profile.packs[ val ] = p

                                        for _, spec in pairs( Hekili.DB.profile.specs ) do
                                            if spec.package == pack then spec.package = val end
                                        end

                                        Hekili:EmbedPackOptions()
                                        Hekili:LoadScripts()
                                        ACD:SelectGroup( "Hekili", "packs", val )
                                    end,
                                    disabled = data.builtIn
                                },

                                copyPack = {
                                    type = "execute",
                                    name = "",
                                    desc = "Copy Priority",
                                    order = 0.26,
                                    width = 0.15,
                                    image = GetAtlasFile( "communities-icon-addgroupplus" ),
                                    imageCoords = GetAtlasCoords( "communities-icon-addgroupplus" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    confirm = function () return "Create a copy of this priority pack?" end,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        local newPack = tableCopy( p )
                                        newPack.builtIn = false
                                        newPack.basedOn = pack

                                        local newPackName, num = pack:match("^(.+) %((%d+)%)$")

                                        if not num then
                                            newPackName = pack
                                            num = 1
                                        end

                                        num = num + 1
                                        while( rawget( Hekili.DB.profile.packs, newPackName .. " (" .. num .. ")" ) ) do
                                            num = num + 1
                                        end
                                        newPackName = newPackName .. " (" .. num ..")"

                                        Hekili.DB.profile.packs[ newPackName ] = newPack
                                        Hekili:EmbedPackOptions()
                                        Hekili:LoadScripts()
                                        ACD:SelectGroup( "Hekili", "packs", newPackName )
                                    end
                                },

                                reloadPack = {
                                    type = "execute",
                                    name = "",
                                    desc = "Reload Priority",
                                    order = 0.27,
                                    width = 0.15,
                                    image = GetAtlasFile( "UI-RefreshButton" ),
                                    imageCoords = GetAtlasCoords( "UI-RefreshButton" ),
                                    imageWidth = 25,
                                    imageHeight = 24,
                                    confirm = function ()
                                        return "Reload this priority pack from defaults?"
                                    end,
                                    hidden = not data.builtIn,
                                    func = function ()
                                        Hekili.DB.profile.packs[ pack ] = nil
                                        Hekili:RestoreDefault( pack )
                                        Hekili:EmbedPackOptions()
                                        Hekili:LoadScripts()
                                        ACD:SelectGroup( "Hekili", "packs", pack )
                                    end
                                },

                                deletePack = {
                                    type = "execute",
                                    name = "",
                                    desc = "Delete Priority",
                                    order = 0.27,
                                    width = 0.15,
                                    image = GetAtlasFile( "common-icon-redx" ),
                                    imageCoords = GetAtlasCoords( "common-icon-redx" ),
                                    imageHeight = 24,
                                    imageWidth = 24,
                                    confirm = function () return "Delete this priority package?" end,
                                    func = function ()
                                        local defPack

                                        local specId = data.spec
                                        local spec = specId and Hekili.DB.profile.specs[ specId ]

                                        if specId then
                                            for pId, pData in pairs( Hekili.DB.profile.packs ) do
                                                if pData.builtIn and pData.spec == specId then
                                                    defPack = pId
                                                    if spec.package == pack then spec.package = pId; break end
                                                end
                                            end
                                        end

                                        Hekili.DB.profile.packs[ pack ] = nil
                                        Hekili.Options.args.packs.plugins.packages[ pack ] = nil

                                        -- Hekili:EmbedPackOptions()
                                        ACD:SelectGroup( "Hekili", "packs" )
                                    end,
                                    hidden = function() return data.builtIn and not Hekili.Version:sub(1, 3) == "Dev" end
                                },

                                lb02 = {
                                    type = "description",
                                    name = "",
                                    order = 0.3,
                                    width = "full",
                                },

                                spec = {
                                    type = "select",
                                    name = "Specialization",
                                    order = 1,
                                    width = 3,
                                    values = specs,
                                    disabled = data.builtIn and not Hekili.Version:sub(1, 3) == "Dev"
                                },

                                lb03 = {
                                    type = "description",
                                    name = "",
                                    order = 1.01,
                                    width = "full",
                                    hidden = data.builtIn
                                },

                                --[[ applyPack = {
                                    type = "execute",
                                    name = "Use Priority",
                                    order = 1.5,
                                    width = 1,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        Hekili.DB.profile.specs[ p.spec ].package = pack
                                    end,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return Hekili.DB.profile.specs[ p.spec ].package == pack
                                    end,
                                }, ]]

                                desc = {
                                    type = "input",
                                    name = "Description",
                                    multiline = 15,
                                    order = 2,
                                    width = "full",
                                },
                            }
                        },

                        profile = {
                            type = "group",
                            name = "Profile",
                            desc = "If this Priority was generated with a SimulationCraft profile, the profile can be stored " ..
                                "or retrieved here.  The profile can also be re-imported or overwritten with a newer profile.",
                            order = 2,
                            args = {
                                signature = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    args = {
                                        source = {
                                            type = "input",
                                            name = "Source",
                                            desc = "If the Priority is based on a SimulationCraft profile or a popular guide, it is a " ..
                                                "good idea to provide a link to the source (especially before sharing).",
                                            order = 1,
                                            width = 3,
                                        },

                                        break1 = {
                                            type = "description",
                                            name = "",
                                            width = "full",
                                            order = 1.1,
                                        },

                                        author = {
                                            type = "input",
                                            name = "Author",
                                            desc = "The author field is automatically filled out when creating a new Priority.  " ..
                                                "You can update it here.",
                                            order = 2,
                                            width = 2,
                                        },

                                        date = {
                                            type = "input",
                                            name = "Last Updated",
                                            desc = "This date is automatically updated when any changes are made to the action lists for this Priority.",
                                            width = 1,
                                            order = 3,
                                            set = function () end,
                                            get = function ()
                                                local d = data.date or 0

                                                if type(d) == "string" then return d end
                                                return format( "%.4f", d )
                                            end,
                                        },
                                    },
                                },

                                profile = {
                                    type = "input",
                                    name = "Profile",
                                    desc = "If this pack's action lists were imported from a SimulationCraft profile, the profile is included here.",
                                    order = 4,
                                    multiline = 20,
                                    width = "full",
                                },

                                warnings = {
                                    type = "input",
                                    name = "Import Log",
                                    order = 5,
                                    -- fontSize = "medium",
                                    width = "full",
                                    multiline = 20,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return not p.warnings or p.warnings == ""
                                    end,
                                },

                                reimport = {
                                    type = "execute",
                                    name = "Import",
                                    desc = "Rebuild the action list(s) from the profile above.",
                                    order = 5,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        local profile = p.profile:gsub( '"', '' )

                                        local result, warnings = Hekili:ImportSimcAPL( nil, nil, profile )

                                        wipe( p.lists )

                                        for k, v in pairs( result ) do
                                            p.lists[ k ] = v
                                        end

                                        p.warnings = warnings
                                        p.date = tonumber( date("%Y%m%d.%H%M%S") )

                                        if not p.lists[ packControl.listName ] then packControl.listName = "default" end

                                        local id = tonumber( packControl.actionID )
                                        if not p.lists[ packControl.listName ][ id ] then packControl.actionID = "zzzzzzzzzz" end

                                        self:LoadScripts()
                                    end,
                                },
                            }
                        },

                        lists = {
                            type = "group",
                            childGroups = "select",
                            name = "Action Lists",
                            desc = "Action Lists are used to determine which abilities should be used at what time.",
                            order = 3,
                            args = {
                                listName = {
                                    type = "select",
                                    name = "Action List",
                                    desc = "Select the action list to view or modify.",
                                    order = 1,
                                    width = 2.7,
                                    values = function ()
                                        local v = {
                                            -- ["zzzzzzzzzz"] = "|cFF00FF00Add New Action List|r"
                                        }

                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        for k in pairs( p.lists ) do
                                            local err = false

                                            if Hekili.Scripts and Hekili.Scripts.DB then
                                                local scriptHead = "^" .. pack .. ":" .. k .. ":"
                                                for k, v in pairs( Hekili.Scripts.DB ) do
                                                    if k:match( scriptHead ) and v.Error then err = true; break end
                                                end
                                            end

                                            if err then
                                                v[ k ] = "|cFFFF0000" .. k .. "|r"
                                            elseif k == 'precombat' or k == 'default' then
                                                v[ k ] = "|cFF00B4FF" .. k .. "|r"
                                            else
                                                v[ k ] = k
                                            end
                                        end

                                        return v
                                    end,
                                },

                                newListBtn = {
                                    type = "execute",
                                    name = "",
                                    desc = "Create a New Action List",
                                    order = 1.1,
                                    width = 0.15,
                                    image = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus",
                                    -- image = GetAtlasFile( "communities-icon-addgroupplus" ),
                                    -- imageCoords = GetAtlasCoords( "communities-icon-addgroupplus" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    func = function ()
                                        packControl.makingNew = true
                                    end,
                                },

                                delListBtn = {
                                    type = "execute",
                                    name = "",
                                    desc = "Delete this Action List",
                                    order = 1.2,
                                    width = 0.15,
                                    image = RedX,
                                    -- image = GetAtlasFile( "common-icon-redx" ),
                                    -- imageCoords = GetAtlasCoords( "common-icon-redx" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    confirm = function() return "Delete this action list?" end,
                                    disabled = function () return packControl.listName == "default" or packControl.listName == "precombat" end,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        p.lists[ packControl.listName ] = nil
                                        Hekili:LoadScripts()
                                        packControl.listName = "default"
                                    end,
                                },

                                lineBreak = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 1.9
                                },

                                actionID = {
                                    type = "select",
                                    name = "Entry",
                                    desc = "Select the entry to modify in this action list.\n\n" ..
                                        "Entries in red are disabled, have no action set, have a conditional error, or use actions that are disabled/toggled off.",
                                    order = 2,
                                    width = 2.4,
                                    values = function ()
                                        local v = {}

                                        local data = rawget( Hekili.DB.profile.packs, pack )
                                        local list = rawget( data.lists, packControl.listName )

                                        if list then
                                            local last = 0

                                            for i, entry in ipairs( list ) do
                                                local key = format( "%04d", i )
                                                local action = entry.action
                                                local desc

                                                local warning, color = false

                                                if not action then
                                                    action = "Unassigned"
                                                    warning = true
                                                else
                                                    if not class.abilities[ action ] then warning = true
                                                    else
                                                        if action == "trinket1" or action == "trinket2" or action == "main_hand" then
                                                            local passthru = "actual_" .. action
                                                            if state:IsDisabled( passthru, true ) then warning = true end
                                                            action = class.abilityList[ passthru ] and class.abilityList[ passthru ] or class.abilities[ passthru ] and class.abilities[ passthru ].name or action
                                                        else
                                                            if state:IsDisabled( action, true ) then warning = true end
                                                            action = class.abilityList[ action ] and class.abilityList[ action ]:match( "|t (.+)$" ) or class.abilities[ action ] and class.abilities[ action ].name or action
                                                        end
                                                    end
                                                end

                                                local scriptID = pack .. ":" .. packControl.listName .. ":" .. i
                                                local script = Hekili.Scripts.DB[ scriptID ]

                                                if script and script.Error then warning = true end

                                                local cLen = entry.criteria and entry.criteria:len()

                                                if entry.caption and entry.caption:len() > 0 then
                                                    desc = entry.caption

                                                elseif entry.action == "variable" then
                                                    if entry.op == "reset" then
                                                        desc = format( "reset |cff00ccff%s|r", entry.var_name or "unassigned" )
                                                    elseif entry.op == "default" then
                                                        desc = format( "|cff00ccff%s|r default = |cffffd100%s|r", entry.var_name or "unassigned", entry.value or "0" )
                                                    elseif entry.op == "set" or entry.op == "setif" then
                                                        desc = format( "set |cff00ccff%s|r = |cffffd100%s|r", entry.var_name or "unassigned", entry.value or "nothing" )
                                                    else
                                                        desc = format( "%s |cff00ccff%s|r (|cffffd100%s|r)", entry.op or "set", entry.var_name or "unassigned", entry.value or "nothing" )
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = format( "%s, if |cffffd100%s|r", desc, entry.criteria )
                                                    end

                                                elseif entry.action == "call_action_list" or entry.action == "run_action_list" then
                                                    if not entry.list_name or not rawget( data.lists, entry.list_name ) then
                                                        desc = "|cff00ccff(not set)|r"
                                                        warning = true
                                                    else
                                                        desc = "|cff00ccff" .. entry.list_name .. "|r"
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = desc .. ", if |cffffd100" .. entry.criteria .. "|r"
                                                    end

                                                elseif entry.action == "cancel_buff" then
                                                    if not entry.buff_name then
                                                        desc = "|cff00ccff(not set)|r"
                                                        warning = true
                                                    else
                                                        local a = class.auras[ entry.buff_name ]

                                                        if a then
                                                            desc = "|cff00ccff" .. a.name .. "|r"
                                                        else
                                                            desc = "|cff00ccff(not found)|r"
                                                            warning = true
                                                        end
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = desc .. ", if |cffffd100" .. entry.criteria .. "|r"
                                                    end

                                                elseif entry.action == "cancel_action" then
                                                    if not entry.action_name then
                                                        desc = "|cff00ccff(not set)|r"
                                                        warning = true
                                                    else
                                                        local a = class.abilities[ entry.action_name ]

                                                        if a then
                                                            desc = "|cff00ccff" .. a.name .. "|r"
                                                        else
                                                            desc = "|cff00ccff(not found)|r"
                                                            warning = true
                                                        end
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = desc .. ", if |cffffd100" .. entry.criteria .. "|r"
                                                    end

                                                elseif cLen and cLen > 0 then
                                                    desc = "|cffffd100" .. entry.criteria .. "|r"

                                                end

                                                if not entry.enabled then
                                                    warning = true
                                                    color = "|cFF808080"
                                                end

                                                if desc then desc = desc:gsub( "[\r\n]", "" ) end

                                                if not color then
                                                    color = warning and "|cFFFF0000" or "|cFFFFD100"
                                                end

                                                if entry.empower_to then
                                                    if entry.empower_to == "max_empower" then
                                                        action = action .. "(Max)"
                                                    else
                                                        action = action .. " (" .. entry.empower_to .. ")"
                                                    end
                                                end

                                                if desc then
                                                    v[ key ] = color .. i .. ".|r " .. action .. " - " .. "|cFFFFD100" .. desc .. "|r"
                                                else
                                                    v[ key ] = color .. i .. ".|r " .. action
                                                end

                                                last = i + 1
                                            end
                                        end

                                        return v
                                    end,
                                    hidden = function ()
                                        return packControl.makingNew == true
                                    end,
                                },

                                moveUpBtn = {
                                    type = "execute",
                                    name = "",
                                    image = "Interface\\AddOns\\Hekili\\Textures\\WhiteUp",
                                    -- image = GetAtlasFile( "hud-MainMenuBar-arrowup-up" ),
                                    -- imageCoords = GetAtlasCoords( "hud-MainMenuBar-arrowup-up" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.1,
                                    func = function( info )
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        local data = p.lists[ packControl.listName ]
                                        local actionID = tonumber( packControl.actionID )

                                        local a = remove( data, actionID )
                                        insert( data, actionID - 1, a )
                                        packControl.actionID = format( "%04d", actionID - 1 )

                                        local listName = format( "%s:%s:", pack, packControl.listName )
                                        scripts:SwapScripts( listName .. actionID, listName .. ( actionID - 1 ) )
                                    end,
                                    disabled = function ()
                                        return tonumber( packControl.actionID ) == 1
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                moveDownBtn = {
                                    type = "execute",
                                    name = "",
                                    image = "Interface\\AddOns\\Hekili\\Textures\\WhiteDown",
                                    -- image = GetAtlasFile( "hud-MainMenuBar-arrowdown-up" ),
                                    -- imageCoords = GetAtlasCoords( "hud-MainMenuBar-arrowdown-up" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.2,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        local data = p.lists[ packControl.listName ]
                                        local actionID = tonumber( packControl.actionID )

                                        local a = remove( data, actionID )
                                        insert( data, actionID + 1, a )
                                        packControl.actionID = format( "%04d", actionID + 1 )

                                        local listName = format( "%s:%s:", pack, packControl.listName )
                                        scripts:SwapScripts( listName .. actionID, listName .. ( actionID + 1 ) )
                                    end,
                                    disabled = function()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return not p.lists[ packControl.listName ] or tonumber( packControl.actionID ) == #p.lists[ packControl.listName ]
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                newActionBtn = {
                                    type = "execute",
                                    name = "",
                                    image = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus",
                                    -- image = GetAtlasFile( "communities-icon-addgroupplus" ),
                                    -- imageCoords = GetAtlasCoords( "communities-icon-addgroupplus" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.3,
                                    func = function()
                                        local data = rawget( self.DB.profile.packs, pack )
                                        if data then
                                            insert( data.lists[ packControl.listName ], { {} } )
                                            packControl.actionID = format( "%04d", #data.lists[ packControl.listName ] )
                                        else
                                            packControl.actionID = "0001"
                                        end
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                delActionBtn = {
                                    type = "execute",
                                    name = "",
                                    image = RedX,
                                    -- image = GetAtlasFile( "common-icon-redx" ),
                                    -- imageCoords = GetAtlasCoords( "common-icon-redx" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.4,
                                    confirm = function() return "Delete this entry?" end,
                                    func = function ()
                                        local id = tonumber( packControl.actionID )
                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        remove( p.lists[ packControl.listName ], id )

                                        if not p.lists[ packControl.listName ][ id ] then id = id - 1; packControl.actionID = format( "%04d", id ) end
                                        if not p.lists[ packControl.listName ][ id ] then packControl.actionID = "zzzzzzzzzz" end

                                        self:LoadScripts()
                                    end,
                                    disabled = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return not p.lists[ packControl.listName ] or #p.lists[ packControl.listName ] < 2
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                --[[ actionGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        if packControl.makingNew or rawget( p.lists, packControl.listName ) == nil or packControl.actionID == "zzzzzzzzzz" then
                                            return true
                                        end
                                        return false
                                    end,
                                    args = {
                                        entry = {
                                            type = "group",
                                            inline = true,
                                            name = "",
                                            order = 2,
                                            -- get = 'GetActionOption',
                                            -- set = 'SetActionOption',
                                            hidden = function( info )
                                                local id = tonumber( packControl.actionID )
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                return not packControl.actionID or packControl.actionID == "zzzzzzzzzz" or not p.lists[ packControl.listName ][ id ]
                                            end,
                                            args = { ]]
                                                enabled = {
                                                    type = "toggle",
                                                    name = "Enabled",
                                                    desc = "If disabled, this entry will not be shown even if its criteria are met.",
                                                    order = 3.0,
                                                    width = "full",
                                                },

                                                action = {
                                                    type = "select",
                                                    name = "Action",
                                                    desc = "Select the action that will be recommended when this entry's criteria are met.",
                                                    values = function()
                                                        local list = {}
                                                        local bypass = {
                                                            trinket1 = actual_trinket1,
                                                            trinket2 = actual_trinket2,
                                                            main_hand = actual_main_hand
                                                        }

                                                        for k, v in pairs( class.abilityList ) do
                                                            list[ k ] = bypass[ k ] or v
                                                        end

                                                        return list
                                                    end,
                                                    sorting = function( a, b )
                                                        local list = {}

                                                        for k in pairs( class.abilityList ) do
                                                            insert( list, k )
                                                        end

                                                        sort( list, function( a, b )
                                                            local bypass = {
                                                                trinket1 = actual_trinket1,
                                                                trinket2 = actual_trinket2,
                                                                main_hand = actual_main_hand
                                                            }
                                                            local aName = bypass[ a ] or class.abilities[ a ].name
                                                            local bName = bypass[ b ] or class.abilities[ b ].name
                                                            if aName ~= nil and type( aName.name ) == "string" then aName = aName.name end
                                                            if bName ~= nil and type( bName.name ) == "string" then bName = bName.name end
                                                            return aName < bName
                                                        end )

                                                        return list
                                                    end,
                                                    order = 3.1,
                                                    width = 1.5,
                                                },

                                                list_name = {
                                                    type = "select",
                                                    name = "Action List",
                                                    values = function ()
                                                        local e = GetListEntry( pack )
                                                        local v = {}

                                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                                        for k in pairs( p.lists ) do
                                                            if k ~= packControl.listName then
                                                                if k == 'precombat' or k == 'default' then
                                                                    v[ k ] = "|cFF00B4FF" .. k .. "|r"
                                                                else
                                                                    v[ k ] = k
                                                                end
                                                            end
                                                        end

                                                        return v
                                                    end,
                                                    order = 3.2,
                                                    width = 1.5,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return not ( e.action == "call_action_list" or e.action == "run_action_list" )
                                                    end,
                                                },

                                                buff_name = {
                                                    type = "select",
                                                    name = "Buff Name",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "Specify the buff to remove.",
                                                    values = class.auraList,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "cancel_buff"
                                                    end,
                                                },

                                                action_name = {
                                                    type = "select",
                                                    name = "Action Name",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "Specify the action to cancel; the result is that the addon will allow the channel to be removed immediately.",
                                                    values = class.abilityList,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "cancel_action"
                                                    end,
                                                },

                                                --[[ potion = {
                                                    type = "select",
                                                    name = "Potion",
                                                    order = 3.2,
                                                    -- width = "full",
                                                    values = class.potionList,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "potion"
                                                    end,
                                                    width = 1.5,
                                                }, ]]

                                                sec = {
                                                    type = "input",
                                                    name = "Seconds",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "wait"
                                                    end,
                                                },

                                                max_energy = {
                                                    type = "toggle",
                                                    name = "Max Energy",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "When checked, this entry will require that the player have enough energy to trigger Ferocious Bite's full damage bonus.",
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "ferocious_bite"
                                                    end,
                                                },

                                                empower_to = {
                                                    type = "select",
                                                    name = "Empower To",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "For Empowered spells, specify the empowerment level for this usage (default is max).",
                                                    values = {
                                                        [1] = "I",
                                                        [2] = "II",
                                                        [3] = "III",
                                                        [4] = "IV",
                                                        max_empower = "Max"
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local action = e.action
                                                        local ability = action and class.abilities[ action ]
                                                        return not ( ability and ability.empowered )
                                                    end,
                                                },

                                                lb00 = {
                                                    type = "description",
                                                    name = "",
                                                    order = 3.201,
                                                    width = "full",
                                                },

                                                caption = {
                                                    type = "input",
                                                    name = "Caption",
                                                    desc = "Captions are |cFFFF0000very|r short descriptions that can appear on the icon of a recommended ability.\n\n" ..
                                                        "This can be useful for understanding why an ability was recommended at a particular time.\n\n" ..
                                                        "Requires Captions to be Enabled on each display.",
                                                    order = 3.202,
                                                    width = 1.5,
                                                    validate = function( info, val )
                                                        val = val:trim()
                                                        if val:len() > 20 then return "Captions should be 20 characters or less." end
                                                        return true
                                                    end,
                                                    hidden = function()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not ability or ( ability.id < 0 and ability.id > -10 )
                                                    end,
                                                },

                                                description = {
                                                    type = "input",
                                                    name = "Description",
                                                    desc = "This allows you to provide text that explains this entry, which will show when you Pause and mouseover the ability to see " ..
                                                        "why this entry was recommended.",
                                                    order = 3.205,
                                                    width = "full",
                                                },

                                                lb01 = {
                                                    type = "description",
                                                    name = "",
                                                    order = 3.21,
                                                    width = "full"
                                                },

                                                var_name = {
                                                    type = "input",
                                                    name = "Variable Name",
                                                    order = 3.3,
                                                    width = 1.5,
                                                    desc = "Specify a name for this variable.  Variables must be lowercase with no spaces or symbols aside from the underscore.",
                                                    validate = function( info, val )
                                                        if val:len() < 3 then return "Variables must be at least 3 characters in length." end

                                                        local check = formatKey( val )
                                                        if check ~= val then return "Invalid characters entered.  Try again." end

                                                        return true
                                                    end,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "variable"
                                                    end,
                                                },

                                                op = {
                                                    type = "select",
                                                    name = "Operation",
                                                    values = {
                                                        add = "Add Value",
                                                        ceil = "Ceiling of Value",
                                                        default = "Set Default Value",
                                                        div = "Divide Value",
                                                        floor = "Floor of Value",
                                                        max = "Maximum of Values",
                                                        min = "Minimum of Values",
                                                        mod = "Modulo of Value",
                                                        mul = "Multiply Value",
                                                        pow = "Raise Value to X Power",
                                                        reset = "Reset to Default",
                                                        set = "Set Value",
                                                        setif = "Set Value If...",
                                                        sub = "Subtract Value",
                                                    },
                                                    order = 3.31,
                                                    width = 1.5,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "variable"
                                                    end,
                                                },

                                                modPooling = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 3.5,
                                                    args = {
                                                        for_next = {
                                                            type = "toggle",
                                                            name = function ()
                                                                local n = packControl.actionID; n = tonumber( n ) + 1
                                                                local e = Hekili.DB.profile.packs[ pack ].lists[ packControl.listName ][ n ]

                                                                local ability = e and e.action and class.abilities[ e.action ]
                                                                ability = ability and ability.name or "Not Set"

                                                                return "Pool for Next Entry (" .. ability ..")"
                                                            end,
                                                            desc = "If checked, the addon will pool resources until the next entry has enough resources to use.",
                                                            order = 5,
                                                            width = 1.5,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "pool_resource"
                                                            end,
                                                        },

                                                        wait = {
                                                            type = "input",
                                                            name = "Pooling Time",
                                                            desc = "Specify the time, in seconds, as a number or as an expression that evaluates to a number.\n" ..
                                                                "Default is |cFFFFD1000.5|r.  An example expression would be |cFFFFD100energy.time_to_max|r.",
                                                            order = 6,
                                                            width = 1.5,
                                                            multiline = 3,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "pool_resource" or e.for_next == 1
                                                            end,
                                                        },

                                                        extra_amount = {
                                                            type = "input",
                                                            name = "Extra Pooling",
                                                            desc = "Specify the amount of extra resources to pool in addition to what is needed for the next entry.",
                                                            order = 6,
                                                            width = 1.5,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "pool_resource" or e.for_next ~= 1
                                                            end,
                                                        },
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= 'pool_resource'
                                                    end,
                                                },

                                                criteria = {
                                                    type = "input",
                                                    name = "Conditions",
                                                    order = 3.6,
                                                    width = "full",
                                                    multiline = 6,
                                                    dialogControl = "HekiliCustomEditor",
                                                    arg = function( info )
                                                        local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )
                                                        local results = {}

                                                        state.reset( "Primary", true )

                                                        local apack = rawget( self.DB.profile.packs, pack )

                                                        -- Let's load variables, just in case.
                                                        for name, alist in pairs( apack.lists ) do
                                                            for i, entry in ipairs( alist ) do
                                                                if name ~= list or i ~= action then
                                                                    if entry.action == "variable" and entry.var_name then
                                                                        state:RegisterVariable( entry.var_name, pack .. ":" .. name .. ":" .. i, name )
                                                                    end
                                                                end
                                                            end
                                                        end

                                                        local entry = apack and apack.lists[ list ]
                                                        entry = entry and entry[ action ]

                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action
                                                        state.scriptID = scriptID
                                                        scripts:StoreValues( results, scriptID )

                                                        return results, list, action
                                                    end,
                                                },

                                                value = {
                                                    type = "input",
                                                    name = "Value",
                                                    desc = "Provide the value to store (or calculate) when this variable is invoked.",
                                                    order = 3.61,
                                                    width = "full",
                                                    multiline = 3,
                                                    dialogControl = "HekiliCustomEditor",
                                                    arg = function( info )
                                                        local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )
                                                        local results = {}

                                                        state.reset( "Primary", true )

                                                        local apack = rawget( self.DB.profile.packs, pack )

                                                        -- Let's load variables, just in case.
                                                        for name, alist in pairs( apack.lists ) do
                                                            for i, entry in ipairs( alist ) do
                                                                if name ~= list or i ~= action then
                                                                    if entry.action == "variable" and entry.var_name then
                                                                        state:RegisterVariable( entry.var_name, pack .. ":" .. name .. ":" .. i, name )
                                                                    end
                                                                end
                                                            end
                                                        end

                                                        local entry = apack and apack.lists[ list ]
                                                        entry = entry and entry[ action ]

                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action
                                                        state.scriptID = scriptID
                                                        scripts:StoreValues( results, scriptID, "value" )

                                                        return results, list, action
                                                    end,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "variable" or e.op == "reset" or e.op == "ceil" or e.op == "floor"
                                                    end,
                                                },

                                                value_else = {
                                                    type = "input",
                                                    name = "Value Else",
                                                    desc = "Provide the value to store (or calculate) if this variable's conditions are not met.",
                                                    order = 3.62,
                                                    width = "full",
                                                    multiline = 3,
                                                    dialogControl = "HekiliCustomEditor",
                                                    arg = function( info )
                                                        local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )
                                                        local results = {}

                                                        state.reset( "Primary", true )

                                                        local apack = rawget( self.DB.profile.packs, pack )

                                                        -- Let's load variables, just in case.
                                                        for name, alist in pairs( apack.lists ) do
                                                            for i, entry in ipairs( alist ) do
                                                                if name ~= list or i ~= action then
                                                                    if entry.action == "variable" and entry.var_name then
                                                                        state:RegisterVariable( entry.var_name, pack .. ":" .. name .. ":" .. i, name )
                                                                    end
                                                                end
                                                            end
                                                        end

                                                        local entry = apack and apack.lists[ list ]
                                                        entry = entry and entry[ action ]

                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action
                                                        state.scriptID = scriptID
                                                        scripts:StoreValues( results, scriptID, "value_else" )

                                                        return results, list, action
                                                    end,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        -- if not e.criteria or e.criteria:trim() == "" then return true end
                                                        return e.action ~= "variable" or e.op == "reset" or e.op == "ceil" or e.op == "floor"
                                                    end,
                                                },

                                                showModifiers = {
                                                    type = "toggle",
                                                    name = "Show Modifiers",
                                                    desc = "If checked, some additional modifiers and conditions may be set.",
                                                    order = 20,
                                                    width = "full",
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not ability -- or ( ability.id < 0 and ability.id > -100 )
                                                    end,
                                                },

                                                modCycle = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 21,
                                                    args = {
                                                        cycle_targets = {
                                                            type = "toggle",
                                                            name = "Cycle Targets",
                                                            desc = "If checked, the addon will check each available target and show whether to switch targets.",
                                                            order = 1,
                                                            width = "single",
                                                        },

                                                        max_cycle_targets = {
                                                            type = "input",
                                                            name = "Max Cycle Targets",
                                                            desc = "If cycle targets is checked, the addon will check up to the specified number of targets.",
                                                            order = 2,
                                                            width = "double",
                                                            disabled = function( info )
                                                                local e = GetListEntry( pack )
                                                                return e.cycle_targets ~= 1
                                                            end,
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modMoving = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 22,
                                                    args = {
                                                        enable_moving = {
                                                            type = "toggle",
                                                            name = "Check Movement",
                                                            desc = "If checked, this entry can only be recommended when your character movement matches the setting.",
                                                            order = 1,
                                                        },

                                                        moving = {
                                                            type = "select",
                                                            name = "Movement",
                                                            desc = "If set, this entry can only be recommended when your movement matches the setting.",
                                                            order = 2,
                                                            width = "double",
                                                            values = {
                                                                [0]  = "Stationary",
                                                                [1]  = "Moving"
                                                            },
                                                            disabled = function( info )
                                                                local e = GetListEntry( pack )
                                                                return not e.enable_moving
                                                            end,
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modAsyncUsage = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 22.1,
                                                    args = {
                                                        use_off_gcd = {
                                                            type = "toggle",
                                                            name = "Use Off GCD",
                                                            desc = "If checked, this entry can be checked even if the global cooldown (GCD) is active.",
                                                            order = 1,
                                                            width = 0.99,
                                                        },
                                                        use_while_casting = {
                                                            type = "toggle",
                                                            name = "Use While Casting",
                                                            desc = "If checked, this entry can be checked even if you are already casting or channeling.",
                                                            order = 2,
                                                            width = 0.99
                                                        },
                                                        only_cwc = {
                                                            type = "toggle",
                                                            name = "During Channel",
                                                            desc = "If checked, this entry can only be used if you are channeling another spell.",
                                                            order = 3,
                                                            width = 0.99
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modCooldown = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 23,
                                                    args = {
                                                        --[[ enable_line_cd = {
                                                            type = "toggle",
                                                            name = "Line Cooldown",
                                                            desc = "If enabled, this entry cannot be recommended unless the specified amount of time has passed since its last use.",
                                                            order = 1,
                                                        }, ]]

                                                        line_cd = {
                                                            type = "input",
                                                            name = "Entry Cooldown",
                                                            desc = "If set, this entry cannot be recommended unless this time has passed since the last time the ability was used.",
                                                            order = 1,
                                                            width = "full",
                                                            --[[ disabled = function( info )
                                                                local e = GetListEntry( pack )
                                                                return not e.enable_line_cd
                                                            end, ]]
                                                        },
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modAPL = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 24,
                                                    args = {
                                                        strict = {
                                                            type = "toggle",
                                                            name = "Strict / Time Insensitive",
                                                            desc = "If checked, the addon will assume this entry is not time-sensitive and will not test actions in the linked priority list if criteria are not presently met.",
                                                            order = 1,
                                                            width = "full",
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or not ( ability.key == "call_action_list" or ability.key == "run_action_list" ) )
                                                    end,
                                                },

                                                --[[ deleteHeader = {
                                                    type = "header",
                                                    name = "Delete Action",
                                                    order = 100,
                                                    hidden = function ()
                                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                                        return #p.lists[ packControl.listName ] < 2 end
                                                },

                                                delete = {
                                                    type = "execute",
                                                    name = "Delete Entry",
                                                    order = 101,
                                                    confirm = true,
                                                    func = function ()
                                                        local id = tonumber( packControl.actionID )
                                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                                        remove( p.lists[ packControl.listName ], id )

                                                        if not p.lists[ packControl.listName ][ id ] then id = id - 1; packControl.actionID = format( "%04d", id ) end
                                                        if not p.lists[ packControl.listName ][ id ] then packControl.actionID = "zzzzzzzzzz" end

                                                        self:LoadScripts()
                                                    end,
                                                    hidden = function ()
                                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                                        return #p.lists[ packControl.listName ] < 2
                                                    end
                                                }
                                            },
                                        },
                                    }
                                }, ]]

                                newListGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 2,
                                    hidden = function ()
                                        return not packControl.makingNew
                                    end,
                                    args = {
                                        newListName = {
                                            type = "input",
                                            name = "List Name",
                                            order = 1,
                                            validate = function( info, val )
                                                local p = rawget( Hekili.DB.profile.packs, pack )

                                                if val:len() < 2 then return "Action list names should be at least 2 characters in length."
                                                elseif rawget( p.lists, val ) then return "There is already an action list by that name."
                                                elseif val:find( "[^a-zA-Z0-9_]" ) then return "Only alphanumeric characters and underscores can be used in list names." end
                                                return true
                                            end,
                                            width = 3,
                                        },

                                        lineBreak = {
                                            type = "description",
                                            name = "",
                                            order = 1.1,
                                            width = "full"
                                        },

                                        createList = {
                                            type = "execute",
                                            name = "Add List",
                                            disabled = function() return packControl.newListName == nil end,
                                            func = function ()
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                p.lists[ packControl.newListName ] = { {} }
                                                packControl.listName = packControl.newListName
                                                packControl.makingNew = false

                                                packControl.actionID = "0001"
                                                packControl.newListName = nil

                                                Hekili:LoadScript( pack, packControl.listName, 1 )
                                            end,
                                            width = 1,
                                            order = 2,
                                        },

                                        cancel = {
                                            type = "execute",
                                            name = "Cancel",
                                            func = function ()
                                                packControl.makingNew = false
                                            end,
                                        }
                                    }
                                },

                                newActionGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    hidden = function ()
                                        return packControl.makingNew or packControl.actionID ~= "zzzzzzzzzz"
                                    end,
                                    args = {
                                        createEntry = {
                                            type = "execute",
                                            name = "Create New Entry",
                                            order = 1,
                                            func = function ()
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                insert( p.lists[ packControl.listName ], {} )
                                                packControl.actionID = format( "%04d", #p.lists[ packControl.listName ] )
                                            end,
                                        }
                                    }
                                }
                            },
                            plugins = {
                            }
                        },

                        export = {
                            type = "group",
                            name = "Export",
                            order = 4,
                            args = {
                                exportString = {
                                    type = "input",
                                    name = "Priority Export String",
                                    desc = "Press CTRL+A to select, then CTRL+C to copy.",
                                    get = function( info )
                                        return SerializeActionPack( pack )
                                    end,
                                    set = function () end,
                                    order = 1,
                                    width = "full"
                                }
                            }
                        }
                    },
                }

                --[[ wipe( opts.args.lists.plugins.lists )

                local n = 10
                for list in pairs( data.lists ) do
                    opts.args.lists.plugins.lists[ list ] = EmbedActionListOptions( n, pack, list )
                    n = n + 1
                end ]]

                packs.plugins.packages[ pack ] = opts
                count = count + 1
            end
        end

        collectgarbage()
        db.args.packs = packs
    end

end


do
    local completed = false
    local SetOverrideBinds

    SetOverrideBinds = function ()
        if InCombatLockdown() then
            C_Timer.After( 5, SetOverrideBinds )
            return
        end

        if completed then
            ClearOverrideBindings( Hekili_Keyhandler )
            completed = false
        end

        for name, toggle in pairs( Hekili.DB.profile.toggles ) do
            if toggle.key and toggle.key ~= "" then
                SetOverrideBindingClick( Hekili_Keyhandler, true, toggle.key, "Hekili_Keyhandler", name )
                completed = true
            end
        end
    end

    function Hekili:OverrideBinds()
        SetOverrideBinds()
    end

    local function SetToggle( info, val )
        local self = Hekili
        local p = self.DB.profile
        local n = #info
        local bind, option = info[ n - 1 ], info[ n ]

        local toggle = p.toggles[ bind ]
        if not toggle then return end

        if option == 'value' then
            if bind == 'pause' then self:TogglePause()
            elseif bind == 'mode' then toggle.value = val
            else self:FireToggle( bind ) end

        elseif option == 'type' then
            toggle.type = val

            if val == "AutoSingle" and not ( toggle.value == "automatic" or toggle.value == "single" ) then toggle.value = "automatic" end
            if val == "AutoDual" and not ( toggle.value == "automatic" or toggle.value == "dual" ) then toggle.value = "automatic" end
            if val == "SingleAOE" and not ( toggle.value == "single" or toggle.value == "aoe" ) then toggle.value = "single" end
            if val == "ReactiveDual" and toggle.value ~= "reactive" then toggle.value = "reactive" end

        elseif option == 'key' then
            for t, data in pairs( p.toggles ) do
                if data.key == val then data.key = "" end
            end

            toggle.key = val
            self:OverrideBinds()

        elseif option == 'override' then
            toggle[ option ] = val
            ns.UI.Minimap:RefreshDataText()

        else
            toggle[ option ] = val

        end
    end

    local function GetToggle( info )
        local self = Hekili
        local p = Hekili.DB.profile
        local n = #info
        local bind, option = info[ n - 1 ], info[ n ]

        local toggle = bind and p.toggles[ bind ]
        if not toggle then return end

        if bind == 'pause' and option == 'value' then return self.Pause end
        return toggle[ option ]
    end

    -- Bindings.
    function Hekili:EmbedToggleOptions( db )
        db = db or self.Options
        if not db then return end

        db.args.toggles = db.args.toggles or {
            type = "group",
            name = "Toggles",
            desc = "Toggles are keybindings that can be used to control which abilities may be recommended and where they are displayed.",
            order = 20,
            childGroups = "tab",
            get = GetToggle,
            set = SetToggle,
            args = {
                cooldowns = {
                    type = "group",
                    name = "Damage Cooldowns",
                    desc = "Toggle Major and Minor Cooldowns to ensure they are recommended at ideal times.",
                    order = 2,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Major Cooldowns",
                            desc = "Set a key to toggle recommendations of Major Cooldowns on or off.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Enable Major Cooldowns",
                            desc = "If checked, abilities and items that require the |cFFFFD100Major Cooldowns|r toggle can be recommended.\n\n"
                                .. "This toggle generally applies to major damage abilities with cooldowns of 60 seconds or greater.\n\n"
                                .. "Abilities may be added/removed from this toggle in |cFFFFD100Abilities|r and/or |cFFFFD100Gear and Items|r sections.",
                            order = 2,
                            width = 2,
                        },

                        cdLineBreak1 = {
                            type = "description",
                            name = "",
                            width = "full",
                            order = 2.1
                        },

                        cdIndent1 = {
                            type = "description",
                            name = "",
                            width = 1,
                            order = 2.2
                        },

                        separate = {
                            type = "toggle",
                            name = format( "Show in Separate %s Cooldowns Display", AtlasToString( "chromietime-32x32" ) ),
                            desc = format( "If checked, abilities controlled by this toggle will be shown separately in your |W%s |cFFFFD100Major Cooldowns|r|w display "
                                .. "when the toggle is enabled.\n\n"
                                .. "This is an experimental feature and may not work well for some specializations.", AtlasToString( "chromietime-32x32" ) ),
                            width = 2,
                            order = 3,
                        },

                        cdLineBreak2 = {
                            type = "description",
                            name = "",
                            width = "full",
                            order = 3.1,
                        },

                        cdIndent2 = {
                            type = "description",
                            name = "",
                            width = 1,
                            order = 3.2
                        },

                        override = {
                            type = "toggle",
                            name = format( "Active During %s", Hekili:GetSpellLinkWithTexture( 2825 ) ),
                            desc = format( "If checked, when any %s effect is active, the |cFFFFD100Major Cooldowns|r toggle will be treated as enabled, even if unchecked.", Hekili:GetSpellLinkWithTexture( 2825 ) ),
                            width = 2,
                            order = 4,
                        },

                        cdLineBreak3 = {
                            type = "description",
                            name = "",
                            width = "full",
                            order = 4.1,
                        },

                        cdIndent3 = {
                            type = "description",
                            name = "",
                            width = 1,
                            order = 4.2
                        },

                        infusion = {
                            type = "toggle",
                            name = format( "Active During %s", Hekili:GetSpellLinkWithTexture( 10060 ) ),
                            desc = format( "If checked, when %s is active, the |cFFFFD100Major Cooldowns|r toggle will be treated as enabled, even if unchecked.", Hekili:GetSpellLinkWithTexture( 10060 ) ),
                            width = 2,
                            order = 5
                        },

                        essences = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 6,
                            args = {
                                key = {
                                    type = "keybinding",
                                    name = "Minor Cooldowns",
                                    desc = "Set a key to toggle recommendations of Minor Cooldowns on or off.",
                                    width = 1,
                                    order = 1,
                                },

                                value = {
                                    type = "toggle",
                                    name = "Enable Minor Cooldowns",
                                    desc = "If checked, abilities that require the |cFFFFD100Minor Cooldowns|r toggle can be recommended.\n\n"
                                        .. "This toggle generally applies to damage-boosting abilities with a cooldown of 30 to 60 seconds, or abilities that you may "
                                        .. "want to control separately from your major cooldowns.\n\n"
                                        .. "Abilities may be added/removed from this toggle in |cFFFFD100Abilities|r and/or |cFFFFD100Gear and Items|r sections.",
                                    width = 2,
                                    order = 2,
                                },

                                --[[ essLineBreak1 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 2.1
                                },

                                essIndent1 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 2.2
                                },

                                separate = {
                                    type = "toggle",
                                    name = format( "Show in Separate %s Cooldowns Display", AtlasToString( "chromietime-32x32" ) ),
                                    desc = format( "If checked, abilities that require the |cFFFFD100Minor Cooldowns|r toggle will be shown separately in your |W%s "
                                        .. "|cFFFFD100Cooldowns|r|w display when the toggle is enabled.\n\n"
                                        .. "This is an experimental feature and may not work well for some specializations.", AtlasToString( "chromietime-32x32" ) ),
                                    width = 2,
                                    order = 3,
                                }, ]]

                                essLineBreak2 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 3.1,
                                },

                                essIndent2 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 3.2
                                },

                                override = {
                                    type = "toggle",
                                    name = "Auto-Enable when |cFFFFD100Major Cooldowns|r Active",
                                    desc = "If checked, when |cFFFFD100Major Cooldowns|r are enabled (or auto-enabled), your |cFFFFD100Minor Cooldowns|r may be recommended even if the toggle itself is not checked.",
                                    width = 2,
                                    order = 4,
                                },
                            }
                        },

                        potions = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 7,
                            args = {
                                key = {
                                    type = "keybinding",
                                    name = "Potions",
                                    desc = "Set a key to toggle recommendations of Potions on or off.",
                                    order = 1,
                                },

                                value = {
                                    type = "toggle",
                                    name = "Enable Potions",
                                    desc = "If checked, abilities that require the |cFFFFD100Potions|r toggle can be recommended.",
                                    width = 2,
                                    order = 2,
                                },

                                --[[ potLineBreak1 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 2.1
                                },

                                potIndent1 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 2.2
                                },

                                separate = {
                                    type = "toggle",
                                    name = format( "Show in Separate %s Cooldowns Display", AtlasToString( "chromietime-32x32" ) ),
                                    desc = format( "If checked, abilities that require the |cFFFFD100Potions|r toggle will be shown separately in your |W%s "
                                        .. "|cFFFFD100Cooldowns|r|w display when the toggle is enabled.\n\n"
                                        .. "This is an experimental feature and may not work well for some specializations.", AtlasToString( "chromietime-32x32" ) ),
                                    width = 2,
                                    order = 3,
                                }, ]]

                                potLineBreak2 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 3.1
                                },

                                potIndent3 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 3.2
                                },

                                override = {
                                    type = "toggle",
                                    name = "Auto-Enable when |cFFFFD100Major Cooldowns|r Active",
                                    desc = "If checked, when |cFFFFD100Major Cooldowns|r are enabled (or auto-enabled), your |cFFFFD100Potions|r may be recommended even if the toggle itself is not checked.",
                                    width = 2,
                                    order = 4,
                                },
                            }
                        },
                    }
                },

                interrupts = {
                    type = "group",
                    name = "Interrupts and Defensives",
                    desc = "Toggle Interrupts (and other utility) and Defensives as needed.",
                    order = 4,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Interrupts",
                            desc = "Set a key to toggle recommendations of Interrupts (or utility abilities) on or off.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Enable Interrupts",
                            desc = "If checked, abilities that require the |cFFFFD100Interrupts|r toggle can be recommended",
                            order = 2,
                        },

                        lb1 = {
                            type = "description",
                            name = "",
                            width = "full",
                            order = 2.1
                        },

                        indent1 = {
                            type = "description",
                            name = "",
                            width = 1,
                            order = 2.2,
                        },

                        separate = {
                            type = "toggle",
                            name = format( "Show in Separate %s Interrupts Display", AtlasToString( "voicechat-icon-speaker-mute" ) ),
                            desc = format( "If checked, abilities that require the |cFFFFD100Interrupts|r toggle will be shown separately in your %s Interrupts display.",
                                AtlasToString( "voicechat-icon-speaker-mute" ) ),
                            width = 2,
                            order = 3,
                        },

                        lb2 = {
                            type = "description",
                            name = "",
                            width = "full",
                            order = 3.1
                        },


                        indent2 = {
                            type = "description",
                            name = "",
                            width = 1,
                            order = 3.2,
                        },

                        filterCasts  ={
                            type = "toggle",
                            name = format( "%s Filter M+ Interrupts (DF Season 4)", NewFeature ),
                            desc = format( "If checked, low-priority enemy casts will be ignored when your target may use an ability that should be interrupted.\n\n"
                                .. "Example:  In Everbloom, Earthshaper Telu's |W%s|w will be ignored and |W%s|w will be interrupted.", ( GetSpellInfo( 168040 ).name or "Nature's Wrath" ),
                                ( GetSpellInfo( 427459 ).name or "Toxic Bloom" ) ),
                            width = 2,
                            order = 4
                        },

                        defensives = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 5,
                            args = {
                                key = {
                                    type = "keybinding",
                                    name = "Defensives",
                                    desc = "Set a key to toggle recommendations of Defensives on or off.\n\n"
                                        .. "This toggle applies primarily to Tank specializations.",
                                    order = 1,
                                },

                                value = {
                                    type = "toggle",
                                    name = "Enable Defensives",
                                    desc = "If checked, abilities that require the |cFFFFD100Defensives|r toggle can be recommended.\n\n"
                                        .. "This toggle applies primarily to Tank specializations.",
                                    order = 2,
                                },

                                lb1 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 2.1
                                },

                                indent1 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 2.2,
                                },

                                separate = {
                                    type = "toggle",
                                    name = format( "Show in Separate %s Defensives Display", AtlasToString( "nameplates-InterruptShield" ) ),
                                    desc = format( "If checked, defensive/mitigation abilities will be shown separately in your |W%s |cFFFFD100Defensives|r|w display.\n\n"
                                        .. "This toggle applies primarily to Tank specializations.", AtlasToString( "nameplates-InterruptShield" ) ),
                                    width = 2,
                                    order = 3,
                                }
                            }
                        },
                    }
                },

                displayModes = {
                    type = "group",
                    name = "Display Control",
                    desc = "Cycle through your preferred Display Modes using the keybinding you select.",
                    order = 10,
                    args = {
                        mode = {
                            type = "group",
                            inline = true,
                            name = "",
                            order = 10.1,
                            args = {
                                key = {
                                    type = 'keybinding',
                                    name = 'Display Mode',
                                    desc = "Pressing this binding will cycle your Display Mode through the options checked below.",
                                    order = 1,
                                    width = 1,
                                },

                                value = {
                                    type = "select",
                                    name = "Select Display Mode",
                                    desc = "Select your Display Mode.",
                                    values = {
                                        automatic = "Automatic",
                                        single = "Single-Target",
                                        aoe = "AOE (Multi-Target)",
                                        dual = "Fixed Dual Display",
                                        reactive = "Reactive Dual Display"
                                    },
                                    width = 1,
                                    order = 1.02,
                                },

                                modeLB2 = {
                                    type = "description",
                                    name = "Select the |cFFFFD100Display Modes|r that you wish to use.  Each time you press your |cFFFFD100Display Mode|r keybinding, the addon will switch to the next checked mode.",
                                    fontSize = "medium",
                                    width = "full",
                                    order = 2
                                },

                                automatic = {
                                    type = "toggle",
                                    name = "Automatic " .. BlizzBlue .. "(Default)|r",
                                    desc = "If checked, the Display Mode toggle can select Automatic mode.\n\nThe Primary display shows recommendations based upon the detected number of enemies (based on your specialization's options).",
                                    width = "full",
                                    order = 3,
                                },

                                autoIndent = {
                                    type = "description",
                                    name = "",
                                    width  = 0.15,
                                    order = 3.1,
                                },

                                --[[ autoDesc = {
                                    type = "description",
                                    name = "Automatic mode uses the Primary display and makes recommendations based on the number of enemies automatically detected.",
                                    width = 2.85,
                                    order = 3.2,
                                }, ]]

                                autoDesc = {
                                    type = "description",
                                    name = format( "%s Uses Primary Display\n"
                                        .. "%s Recommendations based on Targets Detected", Bullet, Bullet ),
                                    fontSize = "medium",
                                    width = 2.85,
                                    order = 3.2
                                },

                                single = {
                                    type = "toggle",
                                    name = "Single-Target",
                                    desc = "If checked, the Display Mode toggle can select Single-Target mode.\n\nThe Primary display shows recommendations as though you have one target (even if more targets are detected).",
                                    width = "full",
                                    order = 4,
                                },

                                singleIndent = {
                                    type = "description",
                                    name = "",
                                    width  = 0.15,
                                    order = 4.1,
                                },

                                --[[ singleDesc = {
                                    type = "description",
                                    name = "Single-Target mode uses the Primary display and makes recommendations as though you have a single target.  This mode can be useful when focusing down an enemy inside a larger group.",
                                    width = 2.85,
                                    order = 4.2,
                                }, ]]

                                singleDesc = {
                                    type = "description",
                                    name = format( "%s Uses Primary Display\n"
                                        .. "%s Recommendations based on 1 Target\n"
                                        .. "%s Useful when Focusing Damage on a High-Priority Enemy", Bullet, Bullet, Bullet ),
                                    fontSize = "medium",
                                    width = 2.85,
                                    order = 4.2
                                },

                                aoe = {
                                    type = "toggle",
                                    name = "AOE (Multi-Target)",
                                    desc = function ()
                                        return format( "If checked, the Display Mode toggle can select AOE mode.\n\nThe Primary display shows recommendations as though you have at least |cFFFFD100%d|r targets (even if fewer are detected).\n\n" ..
                                                        "The number of targets is set in your specialization's options.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = "full",
                                    order = 5,
                                },

                                aoeIndent = {
                                    type = "description",
                                    name = "",
                                    width  = 0.15,
                                    order = 5.1,
                                },

                                --[[ aoeDesc = {
                                    type = "description",
                                    name = function ()
                                        return format( "AOE mode uses the Primary display and makes recommendations as though you have |cFFFFD100%d|r (or more) targets.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = 2.85,
                                    order = 5.2,
                                }, ]]

                                aoeDesc = {
                                    type = "description",
                                    name = function()
                                        return format( "%s Uses Primary Display\n"
                                        .. "%s Recommendations based on at least |cFFFFD100%d|r Targets\n", Bullet, Bullet, self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    fontSize = "medium",
                                    width = 2.85,
                                    order = 5.2
                                },

                                dual = {
                                    type = "toggle",
                                    name = "Dual",
                                    desc = function ()
                                        return format( "If checked, the Display Mode toggle can select Dual mode.\n\nThe Primary display shows single-target recommendations and the AOE display shows recommendations for |cFFFFD100%d|r or more targets (even if fewer are detected).\n\n" ..
                                                        "The number of AOE targets is set in your specialization's options.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = "full",
                                    order = 6,
                                },

                                dualIndent = {
                                    type = "description",
                                    name = "",
                                    width  = 0.15,
                                    order = 6.1,
                                },

                                --[[ dualDesc = {
                                    type = "description",
                                    name = function ()
                                        return format( "Dual mode shows single-target recommendations in the Primary display and multi-target (|cFFFFD100%d|r or more enemies) recommendations in the AOE display.  Both displays are shown at all times.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = 2.85,
                                    order = 6.2,
                                }, ]]

                                dualDesc = {
                                    type = "description",
                                    name = function()
                                        return format( "%s Uses Two Displays: Primary and AOE\n"
                                        .. "%s Primary Display's Recommendations based on 1 Target\n"
                                        .. "%s AOE Display's Recommendations based on at least |cFFFFD100%d|r Targets\n"
                                        .. "%s Useful for Ranged Specializations using Damage-Based Target Detection\n", Bullet, Bullet, Bullet, self.DB.profile.specs[ state.spec.id ].aoe or 3, Bullet )
                                    end,
                                    fontSize = "medium",
                                    width = 2.85,
                                    order = 6.2
                                },

                                reactive = {
                                    type = "toggle",
                                    name = "Reactive Dual Display",
                                    desc = function ()
                                        return format( "If checked, the Display Mode toggle can select Reactive mode.\n\nThe Primary display shows single-target recommendations, while the AOE display remains hidden until/unless |cFFFFD100%d|r or more targets are detected.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = "full",
                                    order = 7,
                                },

                                reactiveIndent = {
                                    type = "description",
                                    name = "",
                                    width  = 0.15,
                                    order = 7.1,
                                },

                                --[[ reactiveDesc = {
                                    type = "description",
                                    name = function ()
                                        return format( "Dual mode shows single-target recommendations in the Primary display and multi-target recommendations in the AOE display.  The Primary display is always active, while the AOE display activates only when |cFFFFD100%d|r or more targets are detected.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = 2.85,
                                    order = 7.2,
                                },]]

                                reactiveDesc = {
                                    type = "description",
                                    name = function() return format( "%s Uses Two Displays: Primary and AOE\n"
                                        .. "%s Primary Display's Recommendations based on 1 Target\n"
                                        .. "%s AOE Display Shown when |cFFFFD100%d|r+ Targets Detected", Bullet, Bullet, Bullet, self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    fontSize = "medium",
                                    width = 2.85,
                                    order = 7.2
                                },
                            },
                        }
                    }
                },

                troubleshooting = {
                    type = "group",
                    name = "Troubleshooting",
                    desc = "These keybindings help provide critical information when troubleshooting or reporting issues.",
                    order = 20,
                    args = {
                        pause = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 1,
                            args = {
                                key = {
                                    type = 'keybinding',
                                    name = function () return Hekili.Pause and "Unpause" or "Pause" end,
                                    desc =  "Set a key to pause processing of your action lists. Your current display(s) will freeze, " ..
                                            "and you can mouseover each icon to see information about the displayed action.\n\n" ..
                                            "This will also create a Snapshot that can be used for troubleshooting and error reporting.",
                                    order = 1,
                                },
                                value = {
                                    type = 'toggle',
                                    name = 'Pause',
                                    order = 2,
                                },
                            }
                        },

                        snapshot = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 2,
                            args = {
                                key = {
                                    type = 'keybinding',
                                    name = 'Snapshot',
                                    desc = "Set a key to make a snapshot (without pausing) that can be viewed on the Snapshots tab.  This can be useful information for testing and debugging.",
                                    order = 1,
                                },
                            }
                        },
                    }
                },

                custom = {
                    type = "group",
                    name = "Custom Toggles",
                    desc = "These toggles allow for the creation of custom keybindings to control specific abilities.",
                    order = 30,
                    args = {
                        custom1 = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 1,
                            args = {
                                key = {
                                    type = "keybinding",
                                    name = "Custom #1",
                                    desc = "Set a key to toggle your first custom set.",
                                    width = 1,
                                    order = 1,
                                },

                                value = {
                                    type = "toggle",
                                    name = "Enable Custom #1",
                                    desc = "If checked, abilities linked to Custom #1 can be recommended.",
                                    width = 2,
                                    order = 2,
                                },

                                lb1 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 2.1
                                },

                                indent1 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 2.2
                                },

                                name = {
                                    type = "input",
                                    name = "Custom #1 Name",
                                    desc = "Specify a descriptive name for this custom toggle.",
                                    width = 2,
                                    order = 3
                                }
                            }
                        },

                        custom2 = {
                            type = "group",
                            name = "",
                            inline = true,
                            order = 30.2,
                            args = {
                                key = {
                                    type = "keybinding",
                                    name = "Custom #2",
                                    desc = "Set a key to toggle your second custom set.",
                                    width = 1,
                                    order = 1,
                                },

                                value = {
                                    type = "toggle",
                                    name = "Enable Custom #2",
                                    desc = "If checked, abilities linked to Custom #2 can be recommended.",
                                    width = 2,
                                    order = 2,
                                },

                                lb1 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 2.1
                                },

                                indent1 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 2.2
                                },

                                name = {
                                    type = "input",
                                    name = "Custom #2 Name",
                                    desc = "Specify a descriptive name for this custom toggle.",
                                    width = 2,
                                    order = 3
                                }
                            }
                        }
                    }
                }
            }
        }
    end
end


do
    -- Generate a spec skeleton.
    local listener = CreateFrame( "Frame" )
    Hekili:ProfileFrame( "SkeletonListener", listener )

    local indent = ""
    local output = {}

    local key = formatKey

    local function increaseIndent()
        indent = indent .. "    "
    end

    local function decreaseIndent()
        indent = indent:sub( 1, indent:len() - 4 )
    end

    local function append( s )
        insert( output, indent .. s )
    end

    local function appendAttr( t, s )
        if t[ s ] ~= nil then
            if type( t[ s ] ) == 'string' then
                insert( output, indent .. s .. ' = "' .. tostring( t[s] ) .. '",' )
            else
                insert( output, indent .. s .. ' = ' .. tostring( t[s] ) .. ',' )
            end
        end
    end

    local spec = ""
    local specID = 0

    local mastery_spell = 0

    local resources = {}
    local talents = {}
    local talentSpells = {}
    local pvptalents = {}
    local auras = {}
    local abilities = {}

    listener:RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED" )
    listener:RegisterEvent( "PLAYER_ENTERING_WORLD" )
    listener:RegisterEvent( "UNIT_AURA" )
    listener:RegisterEvent( "SPELLS_CHANGED" )
    listener:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
    listener:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )

    local applications = {}
    local removals = {}

    local lastAbility = nil
    local lastTime = 0

    local run = 0

    local function EmbedSpellData( spellID, token, talent, pvp )
        local name, _, texture, castTime, minRange, maxRange = GetSpellInfo( spellID )

        local haste = UnitSpellHaste( "player" )
        haste = 1 + ( haste / 100 )

        if name then
            token = token or key( name )

            if castTime % 10 ~= 0 then
                castTime = castTime * haste * 0.001
                castTime = tonumber( format( "%.2f", castTime ) )
            else
                castTime = castTime * 0.001
            end

            local cost, min_cost, max_cost, spendPerSec, cost_percent, resource

            local costs = C_Spell.GetSpellPowerCost( spellID )

            if costs then
                for k, v in pairs( costs ) do
                    if not v.hasRequiredAura or IsPlayerSpell( v.requiredAuraID ) then
                        cost = v.costPercent > 0 and v.costPercent / 100 or v.cost
                        spendPerSec = v.costPerSecond
                        resource = key( v.name )
                        break
                    end
                end
            end

            local passive = IsPassiveSpell( spellID )
            local harmful = IsHarmfulSpell( name )
            local helpful = IsHelpfulSpell( name )

            local _, charges, _, recharge = GetSpellCharges( spellID )
            local cooldown, gcd, icd
                cooldown, gcd = GetSpellBaseCooldown( spellID )
                if cooldown then cooldown = cooldown / 1000 end

            if gcd == 1000 then gcd = "totem"
            elseif gcd == 1500 then gcd = "spell"
            elseif gcd == 0 then gcd = "off"
            else
                icd = gcd / 1000
                gcd = "off"
            end

            if recharge and recharge > cooldown then
                if ( recharge * 1000 ) % 10 ~= 0 then
                    recharge = recharge * haste
                    recharge = tonumber( format( "%.2f", recharge ) )
                end
                cooldown = recharge
            end

            local selfbuff = SpellIsSelfBuff( spellID )
            talent = talent or ( C_Spell.IsClassTalentSpell( spellID ) )

            if selfbuff or passive then
                auras[ token ] = auras[ token ] or {}
                auras[ token ].id = spellID
            end

            local empowered = IsPressHoldReleaseSpell( spellID )
            -- SpellIsTargeting ?

            if not passive then
                local a = abilities[ token ] or {}

                -- a.key = token
                a.desc = GetSpellDescription( spellID ):gsub( "\r", " " ):gsub( "\n", " " ):gsub( "%s%s+", " " )
                a.id = spellID
                a.spend = cost
                a.spendType = resource
                a.spendPerSec = spendPerSec
                a.cast = castTime
                a.empowered = empowered
                a.gcd = gcd or "spell"
                a.icd = icd

                a.texture = texture

                if talent then a.talent = token end
                if pvp then a.pvptalent = token end

                a.startsCombat = harmful == true or helpful == false

                a.cooldown = cooldown
                a.charges = charges
                a.recharge = recharge

                abilities[ token ] = a
            end
        end
    end

    local function CLEU( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceName and UnitIsUnit( sourceName, "player" ) and type( spellName ) == 'string' then
            local now = GetTime()
            local token = key( spellName )

            if subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REFRESH" or
               subtype == "SPELL_PERIODIC_AURA_APPLIED" or subtype == "SPELL_PERIODIC_AURA_APPLIED_DOSE" or subtype == "SPELL_PERIODIC_AURA_REFRESH" then
                -- the last ability probably refreshed this aura.
                if lastAbility and now - lastTime < 0.25 then
                    -- Go ahead and attribute it to the last cast.
                    local a = abilities[ lastAbility ]

                    if a then
                        a.applies = a.applies or {}
                        a.applies[ token ] = spellID
                    end
                else
                    insert( applications, { s = token, i = spellID, t = now } )
                end
            elseif subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REMOVED_DOSE" or subtype == "SPELL_AURA_REMOVED" or
                   subtype == "SPELL_PERIODIC_AURA_REMOVED" or subtype == "SPELL_PERIODIC_AURA_REMOVED_DOSE" or subtype == "SPELL_PERIODIC_AURA_BROKEN" then
                if lastAbility and now - lastTime < 0.25 then
                    -- Go ahead and attribute it to the last cast.
                    local a = abilities[ lastAbility ]

                    if a then
                        a.applies = a.applies or {}
                        a.applies[ token ] = spellID
                    end
                else
                    insert( removals, { s = token, i = spellID, t = now } )
                end
            end
        end
    end

    local function skeletonHandler( self, event, ... )
        local unit = select( 1, ... )

        if ( event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" ) or event == "PLAYER_ENTERING_WORLD" then
            local sID, s = GetSpecializationInfo( GetSpecialization() )
            if specID ~= sID then
                wipe( resources )
                wipe( auras )
                wipe( abilities )
            end
            specID = sID
            spec = s

            mastery_spell = GetSpecializationMasterySpells( GetSpecialization() )

            for k, i in pairs( Enum.PowerType ) do
                if k ~= "NumPowerTypes" and i >= 0 then
                    if UnitPowerMax( "player", i ) > 0 then resources[ k ] = i end
                end
            end


            -- TODO: Rewrite to be a little clearer.
            -- Modified by Wyste in July 2024 to try and fix skeleton building the talents better. 
            -- It could probably be written better
            wipe( talents )
            local configID = C_ClassTalents.GetActiveConfigID() or -1
            local configInfo = C_Traits.GetConfigInfo( configID )
            local specializationName = configInfo.name
            local classCurID = nil
            local specCurID = nil
            local subTrees = C_ClassTalents.GetHeroTalentSpecsForClassSpec ( configID )
            for _, treeID in ipairs( configInfo.treeIDs ) do
                local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo( configID, treeID, false )
                -- 1st key is class points, 2nd key is spec points
                -- per ref: https://wowpedia.fandom.com/wiki/API_C_Traits.GetTreeCurrencyInfo
                classCurID = treeCurrencyInfo[1].traitCurrencyID
                specCurID = treeCurrencyInfo[2].traitCurrencyID
                local nodes = C_Traits.GetTreeNodes( treeID )
                for _, nodeID in ipairs( nodes ) do
                    local node = C_Traits.GetNodeInfo( configID, nodeID )

                    local isHeroSpec = false
                    local isSpecSpec = false

                    if type(C_Traits.GetNodeCost(configID, nodeID)) == "table" then
                        for i, traitCurrencyCost in ipairs (C_Traits.GetNodeCost(configID, nodeID)) do
                            if traitCurrencyCost.ID == specCurID then isSpecSpec = true end
                            if traitCurrencyCost.ID == classCurID then isSpecSpec = false end
                        end
                    end

                    if (node.subTreeID ~= nil ) then
                        specializationName = C_Traits.GetSubTreeInfo( configID, node.subTreeID ).name
                        isHeroSpec = true
                        isSpecSpec = false
                    end

                    if node.maxRanks > 0 then
                        for _, entryID in ipairs( node.entryIDs ) do
                            local entryInfo = C_Traits.GetEntryInfo( configID, entryID )
                            if entryInfo.definitionID then -- Not a subTree (hero talent hidden node)
                                local definitionInfo = C_Traits.GetDefinitionInfo( entryInfo.definitionID )
                                local spellID = definitionInfo and definitionInfo.spellID

                                if spellID then
                                    local name = definitionInfo.overrideName or GetSpellInfo( spellID )
                                    local subtext = spellID and C_Spell.GetSpellSubtext( spellID ) or ""

                                    if subtext then
                                        local rank = subtext:match( "^Rank (%d+)$" )
                                        if rank then name = name .. "_" .. rank end
                                    end

                                    local token = key( name )
                                    insert( talents, { name = token, talent = nodeID, isSpec = isSpecSpec, isHero = isHeroSpec, specName = specializationName, definition = entryInfo.definitionID, spell = spellID, ranks = node.maxRanks } )
                                    if not IsPassiveSpell( spellID ) then EmbedSpellData( spellID, token, true ) end
                                end
                            end
                        end
                    end
                end
            end

            wipe( pvptalents )
            local row = C_SpecializationInfo.GetPvpTalentSlotInfo( 1 )

            for i, tID in ipairs( row.availableTalentIDs ) do
                local _, name, _, _, _, sID = GetPvpTalentInfoByID( tID )
                name = key( name )
                insert( pvptalents, { name = name, talent = tID, spell = sID } )

                if not IsPassiveSpell( sID ) then
                    EmbedSpellData( sID, name, nil, true )
                end
            end

            sort( pvptalents, function( a, b ) return a.name < b.name end )

            for i = 1, GetNumSpellTabs() do
                local tab, _, offset, n = GetSpellTabInfo( i )

                if i == 2 or tab == spec then
                    for j = offset + 1, offset + n do
                        local name, _, texture, castTime, minRange, maxRange, spellID = GetSpellInfo( j, "spell" )
                        if name then EmbedSpellData( spellID, key( name ) ) end
                    end
                end
            end
        elseif event == "SPELLS_CHANGED" then
            for i = 1, GetNumSpellTabs() do
                local tab, _, offset, n = GetSpellTabInfo( i )

                if i == 2 or tab == spec then
                    for j = offset + 1, offset + n do
                        local name, _, texture, castTime, minRange, maxRange, spellID = GetSpellInfo( j, "spell" )
                        if name then EmbedSpellData( spellID, key( name ) ) end
                    end
                end
            end
        elseif event == "UNIT_AURA" then
            if UnitIsUnit( unit, "player" ) or UnitCanAttack( "player", unit ) then
                for i = 1, 40 do
                    local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, _, castByPlayer = UnitBuff( unit, i, "PLAYER" )

                    if not name then break end

                    local token = key( name )

                    local a = auras[ token ] or {}

                    if duration == 0 then duration = 3600 end

                    a.id = spellID
                    a.duration = duration
                    a.type = debuffType
                    a.max_stack = max( a.max_stack or 1, count )

                    auras[ token ] = a
                end

                for i = 1, 40 do
                    local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, _, castByPlayer = UnitDebuff( unit, i, "PLAYER" )

                    if not name then break end

                    local token = key( name )

                    local a = auras[ token ] or {}

                    if duration == 0 then duration = 3600 end

                    a.id = spellID
                    a.duration = duration
                    a.type = debuffType
                    a.max_stack = max( a.max_stack or 1, count )

                    auras[ token ] = a
                end
            end

        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            if UnitIsUnit( "player", unit ) then
                local spellID = select( 3, ... )
                local token = spellID and class.abilities[ spellID ] and class.abilities[ spellID ].key

                local now = GetTime()

                if not token then return end

                lastAbility = token
                lastTime = now

                local a = abilities[ token ]

                if not a then
                    return
                end

                for k, v in pairs( applications ) do
                    if now - v.t < 0.5 then
                        a.applies = a.applies or {}
                        a.applies[ v.s ] = v.i
                    end
                    applications[ k ] = nil
                end

                for k, v in pairs( removals ) do
                    if now - v.t < 0.5 then
                        a.removes = a.removes or {}
                        a.removes[ v.s ] = v.i
                    end
                    removals[ k ] = nil
                end
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            CLEU( event, CombatLogGetCurrentEventInfo() )
        end
    end

    function Hekili:StartListeningForSkeleton()
        -- listener:SetScript( "OnEvent", skeletonHandler )
        skeletonHandler( listener, "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" )
        skeletonHandler( listener, "SPELLS_CHANGED" )
    end


    function Hekili:EmbedSkeletonOptions( db )
        db = db or self.Options
        if not db then return end

        db.args.skeleton = db.args.skeleton or {
            type = "group",
            name = "Skeleton",
            order = 100,
            args = {
                spooky = {
                    type = "input",
                    name = "Skeleton",
                    desc = "A rough skeleton of your current spec, for development purposes only.",
                    order = 1,
                    get = function( info )
                        return Hekili.Skeleton or ""
                    end,
                    multiline = 25,
                    width = "full"
                },
                regen = {
                    type = "execute",
                    name = "Generate Skeleton",
                    order = 2,
                    func = function()
                        skeletonHandler( listener, "PLAYER_SPECIALIZATION_CHANGED", "player" )
                        skeletonHandler( listener, "SPELLS_CHANGED" )

                        run = run + 1

                        indent = ""
                        wipe( output )

                        local playerClass = UnitClass( "player" ):gsub( " ", "" )
                        local playerSpec = select( 2, GetSpecializationInfo( GetSpecialization() ) ):gsub( " ", "" )

                        if run % 2 > 0 then
                            append( "-- " .. playerClass .. playerSpec .. ".lua\n-- " .. date( "%B %Y" ) .. "\n" )
                            append( [[if UnitClassBase( "player" ) ~= "]] .. UnitClassBase( "player" ) .. [[" then return end]] )

                            append( "\nlocal addon, ns = ...\nlocal Hekili = _G[ addon ]\nlocal class, state = Hekili.Class, Hekili.State\n" )

                            append( "local spec = Hekili:NewSpecialization( " .. specID .. " )\n" )

                            for k, i in pairs( resources ) do
                                append( "spec:RegisterResource( Enum.PowerType." .. k .. " )" )
                            end

                            table.sort( talents, function( a, b )
                                return a.name < b.name
                            end )

                            local max_talent_length = 10

                            for i, tal in ipairs( talents ) do
                                local chars = tal.name:len()
                                if chars > max_talent_length then max_talent_length = chars end
                            end

                            local classTalents = {}
                            local specTalents = {}
                            local hero1Talents = {}
                            local hero2Talents = {}
                            local specName = nil
                            local firstHeroSpec = nil
                            local secondHeroSpec = nil

                            for i, tal in ipairs( talents) do
                                if ( tal.isSpec == false and tal.isHero == false ) then
                                    insert( classTalents, tal )
                                end
                                if ( tal.isSpec == true and tal.isHero == false ) then
                                    if ( specName == nil ) then specName = tal.specName end
                                    insert( specTalents, tal )
                                end
                                if (tal.isSpec == false and tal.isHero == true ) then
                                    if ( firstHeroSpec == nil ) then 
                                        firstHeroSpec = tal.specName 
                                    end

                                    if ( tal.specName == firstHeroSpec ) then
                                        insert( hero1Talents, tal )
                                    else
                                        if ( secondHeroSpec == nil ) then secondHeroSpec = tal.specName end
                                        insert( hero2Talents, tal )
                                    end
                                end
                            end

                            append( "" )
                            append( "-- Talents" )
                            append( "spec:RegisterTalents( {" )
                            increaseIndent()
                            local formatStr = "%-" .. max_talent_length .. "s = { %6d, %6d, %d }, -- %s"

                            -- Write Class Talents
                            append( "-- " .. playerClass )
                            for i, tal in ipairs( classTalents ) do
                                local line = format( formatStr, tal.name, tal.talent, tal.spell, tal.ranks or 0, GetSpellDescription( tal.spell ):gsub( "\n", " " ):gsub( "\r", " " ):gsub( "%s%s+", " " ) )
                                append( line )
                            end

                            -- Write Spec Talents
                            append( "" )
                            append( "-- " .. specName )
                            for i, tal in ipairs( specTalents ) do
                                local line = format( formatStr, tal.name, tal.talent, tal.spell, tal.ranks or 0, GetSpellDescription( tal.spell ):gsub( "\n", " " ):gsub( "\r", " " ):gsub( "%s%s+", " " ) )
                                append( line )
                            end
                            
                            -- Write Hero1 Talents
                            append( "" )
                            append( "-- " .. firstHeroSpec )
                            for i, tal in ipairs( hero1Talents ) do
                                local line = format( formatStr, tal.name, tal.talent, tal.spell, tal.ranks or 0, GetSpellDescription( tal.spell ):gsub( "\n", " " ):gsub( "\r", " " ):gsub( "%s%s+", " " ) )
                                append( line )
                            end

                            -- Write Hero2 Talents
                            append( "" )
                            append( "-- " .. secondHeroSpec )
                            for i, tal in ipairs( hero2Talents ) do
                                local line = format( formatStr, tal.name, tal.talent, tal.spell, tal.ranks or 0, GetSpellDescription( tal.spell ):gsub( "\n", " " ):gsub( "\r", " " ):gsub( "%s%s+", " " ) )
                                append( line )
                            end
                            decreaseIndent()
                            append( "} )\n\n" )

                            append( "-- PvP Talents" )
                            append( "spec:RegisterPvpTalents( { " )
                            increaseIndent()

                            local max_pvptalent_length = 10
                            for i, tal in ipairs( pvptalents ) do
                                local chars = tal.name:len()
                                if chars > max_pvptalent_length then max_pvptalent_length = chars end
                            end

                            local formatPvp = "%-" .. max_pvptalent_length .. "s = %4d, -- (%d) %s"

                            for i, tal in ipairs( pvptalents ) do
                                append( format( formatPvp, tal.name, tal.talent, tal.spell, GetSpellDescription( tal.spell ):gsub( "\n", " " ):gsub( "\r", " " ):gsub( "%s%s+", " " ) ) )
                            end
                            decreaseIndent()
                            append( "} )\n\n" )

                            append( "-- Auras" )
                            append( "spec:RegisterAuras( {" )
                            increaseIndent()

                            for k, aura in orderedPairs( auras ) do
                                if aura.desc then append( "-- " .. aura.desc ) end
                                append( k .. " = {" )
                                increaseIndent()
                                append( "id = " .. aura.id .. "," )

                                for key, value in pairs( aura ) do
                                    if key ~= "id" then
                                        if type(value) == 'string' then
                                            append( key .. ' = "' .. value .. '",' )
                                        else
                                            append( key .. " = " .. value .. "," )
                                        end
                                    end
                                end

                                decreaseIndent()
                                append( "}," )
                            end

                            decreaseIndent()
                            append( "} )\n\n" )


                            append( "-- Abilities" )
                            append( "spec:RegisterAbilities( {" )
                            increaseIndent()

                            local count = 1
                            for k, a in orderedPairs( abilities ) do
                                count = count + 1
                                if a.desc then append( "-- " .. a.desc ) end
                                append( k .. " = {" )
                                increaseIndent()
                                appendAttr( a, "id" )
                                appendAttr( a, "cast" )
                                appendAttr( a, "charges" )
                                appendAttr( a, "cooldown" )
                                appendAttr( a, "recharge" )
                                appendAttr( a, "gcd" )
                                if a.icd ~= nil then appendAttr( a, "icd" ) end
                                append( "" )
                                appendAttr( a, "spend" )
                                appendAttr( a, "spendPerSec" )
                                appendAttr( a, "spendType" )
                                if a.spend ~= nil or a.spendPerSec ~= nil or a.spendType ~= nil then
                                    append( "" )
                                end
                                appendAttr( a, "talent" )
                                appendAttr( a, "pvptalent" )
                                appendAttr( a, "startsCombat" )
                                appendAttr( a, "texture" )
                                append( "" )
                                if a.cooldown >= 60 then append( "toggle = \"cooldowns\",\n" ) end
                                append( "handler = function ()" )

                                if a.applies or a.removes then
                                    increaseIndent()
                                    if a.applies then
                                        for name, id in pairs( a.applies ) do
                                            append( "-- applies " .. name .. " (" .. id .. ")" )
                                        end
                                    end
                                    if a.removes then
                                        for name, id in pairs( a.removes ) do
                                            append( "-- removes " .. name .. " (" .. id .. ")" )
                                        end
                                    end
                                    decreaseIndent()
                                end
                                append( "end," )
                                decreaseIndent()
                                append( "}," )
                            end

                            decreaseIndent()
                            append( "} )" )

                            append( "\nspec:RegisterPriority( \"" .. playerSpec .. "\", " .. date( "%Y%m%d" ) .. ",\n-- Notes\n" ..
                                "[[\n\n" ..
                                "]],\n-- Priority\n" ..
                                "[[\n\n" ..
                                "]] )" )
                        else
                            local aggregate = {}

                            for k,v in pairs( auras ) do
                                if not aggregate[k] then aggregate[k] = {} end
                                aggregate[k].id = v.id
                                aggregate[k].aura = true
                            end

                            for k,v in pairs( abilities ) do
                                if not aggregate[k] then aggregate[k] = {} end
                                aggregate[k].id = v.id
                                aggregate[k].ability = true
                            end

                            for k,v in pairs( talents ) do
                                if not aggregate[v.name] then aggregate[v.name] = {} end
                                aggregate[v.name].id = v.spell
                                aggregate[v.name].talent = true
                            end

                            for k,v in pairs( pvptalents ) do
                                if not aggregate[v.name] then aggregate[v.name] = {} end
                                aggregate[v.name].id = v.spell
                                aggregate[v.name].pvptalent = true
                            end

                            -- append( select( 2, GetSpecializationInfo(GetSpecialization())) .. "\nKey\tID\tIs Aura\tIs Ability\tIs Talent\tIs PvP" )
                            for k,v in orderedPairs( aggregate ) do
                                if v.id then
                                    append( k .. "\t" .. v.id .. "\t" .. ( v.aura and "Yes" or "No" ) .. "\t" .. ( v.ability and "Yes" or "No" ) .. "\t" .. ( v.talent and "Yes" or "No" ) .. "\t" .. ( v.pvptalent and "Yes" or "No" ) .. "\t" .. ( v.desc or GetSpellDescription( v.id ) or "" ):gsub( "\r", " " ):gsub( "\n", " " ):gsub( "%s%s+", " " ) )
                                end
                            end
                        end

                        Hekili.Skeleton = table.concat( output, "\n" )
                    end,
                }
            },
            hidden = function()
                return not Hekili.Skeleton
            end,
        }

    end
end


do
    local selectedError = nil
    local errList = {}

    function Hekili:EmbedErrorOptions( db )
        db = db or self.Options
        if not db then return end

        db.args.errors = {
            type = "group",
            name = "Warnings",
            order = 99,
            args = {
                errName = {
                    type = "select",
                    name = "Warning Identifier",
                    width = "full",
                    order = 1,

                    values = function()
                        wipe( errList )

                        for i, err in ipairs( self.ErrorKeys ) do
                            local eInfo = self.ErrorDB[ err ]

                            errList[ i ] = "[" .. eInfo.last .. " (" .. eInfo.n .. "x)] " .. err
                        end

                        return errList
                    end,

                    get = function() return selectedError end,
                    set = function( info, val ) selectedError = val end,
                },

                errorInfo = {
                    type = "input",
                    name = "Warning Information",
                    width = "full",
                    multiline = 10,
                    order = 2,

                    get = function ()
                        if selectedError == nil then return "" end
                        return Hekili.ErrorKeys[ selectedError ]
                    end,

                    dialogControl = "HekiliCustomEditor",
                }
            },
            disabled = function() return #self.ErrorKeys == 0 end,
        }
    end
end


function Hekili:GenerateProfile()
    local s = state

    local spec = s.spec.key

    local talents = self:GetLoadoutExportString()

    for k, v in orderedPairs( s.talent ) do
        if v.enabled then
            if talents then talents = format( "%s\n    %s = %d/%d", talents, k, v.rank, v.max )
            else talents = format( "%s = %d/%d", k, v.rank, v.max ) end
        end
    end

    local pvptalents
    for k,v in orderedPairs( s.pvptalent ) do
        if v.enabled then
            if pvptalents then pvptalents = format( "%s\n   %s", pvptalents, k )
            else pvptalents = k end
        end
    end

    local covenants = { "kyrian", "necrolord", "night_fae", "venthyr" }
    local covenant = "none"
    for i, v in ipairs( covenants ) do
        if state.covenant[ v ] then covenant = v; break end
    end

    local conduits
    for k,v in orderedPairs( s.conduit ) do
        if v.enabled then
            if conduits then conduits = format( "%s\n   %s = %d", conduits, k, v.rank )
            else conduits = format( "%s = %d", k, v.rank ) end
        end
    end

    local soulbinds

    local activeBind = C_Soulbinds.GetActiveSoulbindID()
    if activeBind then
        soulbinds = "[" .. formatKey( C_Soulbinds.GetSoulbindData( activeBind ).name ) .. "]"
    end

    for k,v in orderedPairs( s.soulbind ) do
        if v.enabled then
            if soulbinds then soulbinds = format( "%s\n   %s = %d", soulbinds, k, v.rank )
            else soulbinds = format( "%s = %d", k, v.rank ) end
        end
    end

    local sets
    for k, v in orderedPairs( class.gear ) do
        if s.set_bonus[ k ] > 0 then
            if sets then sets = format( "%s\n    %s = %d", sets, k, s.set_bonus[k] )
            else sets = format( "%s = %d", k, s.set_bonus[k] ) end
        end
    end

    local gear, items
    for k, v in orderedPairs( state.set_bonus ) do
        if type(v) == "number" and v > 0 then
            if type(k) == 'string' then
                if gear then gear = format( "%s\n    %s = %d", gear, k, v )
                else gear = format( "%s = %d", k, v ) end
            elseif type(k) == 'number' then
                if items then items = format( "%s, %d", items, k )
                else items = tostring(k) end
            end
        end
    end

    local legendaries
    for k, v in orderedPairs( state.legendary ) do
        if k ~= "no_trait" and v.rank > 0 then
            if legendaries then legendaries = format( "%s\n    %s = %d", legendaries, k, v.rank )
            else legendaries = format( "%s = %d", k, v.rank ) end
        end
    end

    local settings
    if state.settings.spec then
        for k, v in orderedPairs( state.settings.spec ) do
            if type( v ) ~= "table" then
                if settings then settings = format( "%s\n    %s = %s", settings, k, tostring( v ) )
                else settings = format( "%s = %s", k, tostring( v ) ) end
            end
        end
        for k, v in orderedPairs( state.settings.spec.settings ) do
            if type( v ) ~= "table" then
                if settings then settings = format( "%s\n    %s = %s", settings, k, tostring( v ) )
                else settings = format( "%s = %s", k, tostring( v ) ) end
            end
        end
    end

    local toggles
    for k, v in orderedPairs( self.DB.profile.toggles ) do
        if type( v ) == "table" and rawget( v, "value" ) ~= nil then
            if toggles then toggles = format( "%s\n    %s = %s %s", toggles, k, tostring( v.value ), ( v.separate and "[separate]" or ( k ~= "cooldowns" and v.override and self.DB.profile.toggles.cooldowns.value and "[overridden]" ) or "" ) )
            else toggles = format( "%s = %s %s", k, tostring( v.value ), ( v.separate and "[separate]" or ( k ~= "cooldowns" and v.override and self.DB.profile.toggles.cooldowns.value and "[overridden]" ) or "" ) ) end
        end
    end

    local keybinds = ""
    local bindLength = 1

    for name in pairs( Hekili.KeybindInfo ) do
        if name:len() > bindLength then
            bindLength = name:len()
        end
    end

    for name, data in orderedPairs( Hekili.KeybindInfo ) do
        local action = format( "%-" .. bindLength .. "s =", name )
        local count = 0
        for i = 1, 12 do
            local bar = data.upper[ i ]
            if bar then
                if count > 0 then action = action .. "," end
                action = format( "%s %-4s[%02d]", action, bar, i )
                count = count + 1
            end
        end
        keybinds = keybinds .. "\n    " .. action
    end


    local warnings

    for i, err in ipairs( Hekili.ErrorKeys ) do
        if warnings then warnings = format( "%s\n[#%d] %s", warnings, i, err:gsub( "\n\n", "\n" ) )
        else warnings = format( "[#%d] %s", i, err:gsub( "\n\n", "\n" ) ) end
    end


    return format( "build: %s\n" ..
        "level: %d (%d)\n" ..
        "class: %s\n" ..
        "spec: %s\n\n" ..
        "talents: %s\n\n" ..
        "pvptalents: %s\n\n" ..
        "covenant: %s\n\n" ..
        "conduits: %s\n\n" ..
        "soulbinds: %s\n\n" ..
        "sets: %s\n\n" ..
        "gear: %s\n\n" ..
        "legendaries: %s\n\n" ..
        "itemIDs: %s\n\n" ..
        "settings: %s\n\n" ..
        "toggles: %s\n\n" ..
        "keybinds: %s\n\n" ..
        "warnings: %s\n\n",
        self.Version or "no info",
        UnitLevel( 'player' ) or 0, UnitEffectiveLevel( 'player' ) or 0,
        class.file or "NONE",
        spec or "none",
        talents or "none",
        pvptalents or "none",
        covenant or "none",
        conduits or "none",
        soulbinds or "none",
        sets or "none",
        gear or "none",
        legendaries or "none",
        items or "none",
        settings or "none",
        toggles or "none",
        keybinds or "none",
        warnings or "none" )
end


do
    local Options = {
        name = "Hekili " .. Hekili.Version,
        type = "group",
        handler = Hekili,
        get = 'GetOption',
        set = 'SetOption',
        childGroups = "tree",
        args = {
            general = {
                type = "group",
                name = "General",
                desc = "Welcome to Hekili; includes general information and essential links.",
                order = 10,
                childGroups = "tab",
                args = {
                    enabled = {
                        type = "toggle",
                        name = "Enabled",
                        desc = "Enables or disables the addon.",
                        order = 1
                    },

                    minimapIcon = {
                        type = "toggle",
                        name = "Hide Minimap Icon",
                        desc = "If checked, the minimap icon will be hidden.",
                        order = 2,
                    },

                    monitorPerformance = {
                        type = "toggle",
                        name = BlizzBlue .. "Monitor Performance|r",
                        desc = "If checked, the addon will track processing time and volume of events.",
                        order = 3,
                        hidden = function()
                            return not Hekili.Version:match("Dev")
                        end,
                    },

                    welcome = {
                        type = 'description',
                        name = "",
                        fontSize = "medium",
                        image = "Interface\\Addons\\Hekili\\Textures\\Taco256",
                        imageWidth = 96,
                        imageHeight = 96,
                        order = 5,
                        width = "full"
                    },

                    supporters = {
                        type = "description",
                        name = function ()
                            return "|cFF00CCFFTHANK YOU TO OUR SUPPORTERS!|r\n\n" .. ns.Patrons .. "\n\n" ..
                                "Please see the |cFFFFD100Issue Reports|r link for information about reporting bugs.\n\n"
                        end,
                        fontSize = "medium",
                        order = 6,
                        width = "full"
                    },

                    curse = {
                        type = "input",
                        name = "Curse",
                        order = 10,
                        get = function () return "https://www.curseforge.com/wow/addons/hekili" end,
                        set = function () end,
                        width = "full",
                        dialogControl = "SFX-Info-URL",
                    },

                    github = {
                        type = "input",
                        name = "GitHub",
                        order = 11,
                        get = function () return "https://github.com/Hekili/hekili/" end,
                        set = function () end,
                        width = "full",
                        dialogControl = "SFX-Info-URL",
                    },

                    link = {
                        type = "input",
                        name = "Issue Reports",
                        order = 12,
                        width = "full",
                        get = function() return "http://github.com/Hekili/hekili/issues" end,
                        set = function() end,
                        dialogControl = "SFX-Info-URL"
                    },
                    faq = {
                        type = "input",
                        name = "FAQ / Help",
                        order = 13,
                        width = "full",
                        get = function() return "https://github.com/Hekili/hekili/wiki/Frequently-Asked-Questions" end,
                        set = function() end,
                        dialogControl = "SFX-Info-URL"
                    },
                    simulationcraft = {
                        type = "input",
                        name = "SimC",
                        order = 14,
                        get = function () return "https://github.com/simulationcraft/simc/wiki" end,
                        set = function () end,
                        width = "full",
                        dialogControl = "SFX-Info-URL",
                    }
                }
            },


            --[[ gettingStarted = {
                type = "group",
                name = "Getting Started",
                order = 11,
                childGroups = "tree",
                args = {
                    q1 = {
                        type = "header",
                        name = "Moving the Displays",
                        order = 1,
                        width = "full"
                    },
                    a1 = {
                        type = "description",
                        name = "When these options are open, all displays are visible and can be moved by clicking and dragging.  You can move this options screen out of the way by clicking the |cFFFFD100Hekili|r title and dragging it out of the way.\n\n" ..
                            "You can also set precise X/Y positioning in the |cFFFFD100Displays|r section, on each display's |cFFFFD100Main|r tab.\n\n" ..
                            "You can also move the displays by typing |cFFFFD100/hek move|r in chat.  Type |cFFFFD100/hek move|r again to lock the displays.\n",
                        order = 1.1,
                        width = "full",
                    },

                    q2 = {
                        type = "header",
                        name = "Using Toggles",
                        order = 2,
                        width = "full",
                    },
                    a2 = {
                        type = "description",
                        name = "The addon has several |cFFFFD100Toggles|r available that help you control the type of recommendations you receive while in combat.  See the |cFFFFD100Toggles|r section for specifics.\n\n" ..
                            "|cFFFFD100Mode|r:  By default, |cFFFFD100Automatic Mode|r automatically detects how many targets you are engaged with, and gives recommendations based on the number of targets detected.  In some circumstances, you may want the addon to pretend there is only 1 target, or that there are multiple targets, " ..
                            "or show recommendations for both scenarios.  You can use the |cFFFFD100Mode|r toggle to swap between Automatic, Single-Target, AOE, and Reactive modes.\n\n" ..
                            "|cFFFFD100Abilities|r:  Some of your abilities can be controlled by specific toggles.  For example, your major DPS cooldowns are assigned to the |cFFFFD100Cooldowns|r toggle.  This feature allows you to enable/disable these abilities in combat by using the assigned keybinding.  You can add abilities to (or remove abilities from) " ..
                            "these toggles in the |cFFFFD100Abilities|r or |cFFFFD100Gear and Trinkets|r sections.  When removed from a toggle, an ability can be recommended at any time, regardless of whether that toggle is on or off.\n\n" ..
                            "|cFFFFD100Displays|r:  Your Interrupts, Defensives, and Cooldowns toggles have a special relationship with the displays of the same names.  If |cFFFFD100Show Separately|r is checked for that toggle, those abilities will show in that toggle's display instead of the |cFFFFD100Primary|r or |cFFFFD100AOE|r display.\n",
                        order = 2.1,
                        width = "full",
                    },

                    q3 = {
                        type = "header",
                        name = "Importing a Profile",
                        order = 3,
                        width = "full",
                    },
                    a3 = {
                        type = "description",
                        name = "|cFFFF0000You do not need to import a SimulationCraft profile to use this addon.|r\n\n" ..
                            "Before trying to import a profile, please consider the following:\n\n" ..
                            " - SimulationCraft action lists tend not to change significantly for individual characters.  The profiles are written to include conditions that work for all gear, talent, and other factors combined.\n\n" ..
                            " - Most SimulationCraft action lists require some additional customization to work with the addon.  For example, |cFFFFD100target_if|r conditions don't translate directly to the addon and have to be rewritten.\n\n" ..
                            " - Some SimulationCraft action profiles are revised for the addon to be more efficient and use less processing time.\n\n" ..
                            "The default priorities included within the addon are kept up to date, are compatible with your character, and do not require additional changes.  |cFFFF0000No support is offered for custom or imported priorities from elsewhere.|r\n",
                        order = 3.1,
                        width = "full",
                    },

                    q4 = {
                        type = "header",
                        name = "Something's Wrong",
                        order = 4,
                        width = "full",
                    },
                    a4 = {
                        type = "description",
                        name = "You can submit questions, concerns, and ideas via the link found in the |cFFFFD100Issue Reporting|r section.\n\n" ..
                            "If you disagree with the addon's recommendations, the |cFFFFD100Snapshot|r feature allows you to capture a log of the addon's decision-making taken at the exact moment specific recommendations are shown.  " ..
                            "When you submit your question, be sure to take a snapshot (not a screenshot!), place the text on Pastebin, and include the link when you submit your issue ticket.",
                        order = 4.1,
                        width = "full",
                    }
                }
            }, ]]

            abilities = {
                type = "group",
                name = "技能",
                desc = "編輯特定技能，例如停用、分配切換、覆蓋按鍵綁定文字或圖示等。",
                order = 80,
                childGroups = "select",
                args = {
                    spec = {
                        type = "select",
                        name = "專精",
                        desc = "這些選項會套用到所選的專精。",
                        order = 0.1,
                        width = "full",
                        set = SetCurrentSpec,
                        get = GetCurrentSpec,
                        values = GetCurrentSpecList,
                    },
                },
                plugins = {
                    actions = {}
                }
            },

            items = {
                type = "group",
                name = "Gear and Items",
                desc = "Edit specific items, such as disabling, assigning to a toggle, overriding the keybind text and more.",
                order = 81,
                childGroups = "select",
                args = {
                    spec = {
                        type = "select",
                        name = "Specialization",
                        desc = "These options apply to your selected specialization.",
                        order = 0.1,
                        width = "full",
                        set = SetCurrentSpec,
                        get = GetCurrentSpec,
                        values = GetCurrentSpecList,
                    },
                },
                plugins = {
                    equipment = {}
                }
            },

            snapshots = {
                type = "group",
                name = "Issue Reporting (Snapshots)",
                desc = "Learn how to report an issue with the addon, such as incorrect recommendations or bugs.",
                order = 86,
                args = {
                    autoSnapshot = {
                        type = "toggle",
                        name = "Auto Snapshot",
                        desc = "If checked, the addon will automatically create a snapshot whenever it failed to generate a recommendation.\n\n" ..
                            "This automatic snapshot can only occur once per episode of combat.",
                        order = 1,
                        width = "full",
                    },

                    screenshot = {
                        type = "toggle",
                        name = "Take Screenshot",
                        desc = "If checked, the addon will take a screenshot when you manually create a snapshot.\n\n" ..
                            "Submitting both with your issue tickets will provide useful information for investigation purposes.",
                        order = 2,
                        width = "full",
                    },

                    prefHeader = {
                        type = "header",
                        name = "Snapshots / Troubleshooting",
                        order = 2.5,
                        width = "full"
                    },

                    header = {
                        type = "description",
                        name = function()
                            return "Snapshots are logs of the addon's decision-making process for a set of recommendations.  If you have questions about -- or disagree with -- the addon's recommendations, " ..
                            "reviewing a snapshot can help identify what factors led to the specific recommendations that you saw.\n\n" ..
                            "Snapshots only capture a specific point in time, so snapshots have to be taken at the time you saw the specific recommendations that you are concerned about.  You can generate " ..
                            "snapshots by using the |cffffd100Snapshot|r binding ( |cffffd100" .. ( Hekili.DB.profile.toggles.snapshot.key or "NOT BOUND" ) .. "|r ) from the Toggles section.\n\n" ..
                            "You can also freeze the addon's recommendations using the |cffffd100Pause|r binding ( |cffffd100" .. ( Hekili.DB.profile.toggles.pause.key or "NOT BOUND" ) .. "|r ).  Doing so will freeze the addon's recommendations, allowing you to mouseover the display " ..
                            "and see which conditions were met to display those recommendations.  Press Pause again to unfreeze the addon.\n\n" ..
                            "Finally, using the settings at the bottom of this panel, you can ask the addon to automatically generate a snapshot for you when no recommendations were able to be made.\n\n"
                        end,
                        fontSize = "medium",
                        order = 10,
                        width = "full",
                    },

                    SnapID = {
                        type = "select",
                        name = "Select Entry",
                        desc = "Select a Snapshot to export.",
                        values = function( info )
                            if #ns.snapshots == 0 then
                                snapshots.snaps[ 0 ] = "No snapshots have been generated."
                            else
                                snapshots.snaps[ 0 ] = nil
                                for i, snapshot in ipairs( ns.snapshots ) do
                                    snapshots.snaps[ i ] = "|cFFFFD100" .. i .. ".|r " .. snapshot.header
                                end
                            end

                            return snapshots.snaps
                        end,
                        set = function( info, val )
                            snapshots.selected = val
                        end,
                        get = function( info )
                            return snapshots.selected
                        end,
                        order = 12,
                        width = "full",
                        disabled = function() return #ns.snapshots == 0 end,
                    },

                    Snapshot = {
                        type = 'input',
                        name = "Snapshot",
                        desc = "Click here and press CTRL+A, CTRL+C to copy the snapshot.\n\nPaste in a text editor to review or upload to Pastebin to support an issue ticket.",
                        order = 20,
                        get = function( info )
                            if snapshots.selected == 0 then return "" end
                            return ns.snapshots[ snapshots.selected ].log
                        end,
                        set = function() end,
                        width = "full",
                        hidden = function() return snapshots.selected == 0 or #ns.snapshots == 0 end,
                    },

                    SnapshotInstructions = {
                        type = "description",
                        name = "Click the Snapshot and press CTRL+A, CTRL+C to select all text and copy it to the clipboard.\n\n"
                            .. "Paste the text into a text editor for your own review, or upload to Pastebin to link to an issue report on GitHub.",
                        order = 30,
                        width = "full",
                        hidden = function() return snapshots.selected == 0 or #ns.snapshots == 0 end,
                    }
                }
            },
        },

        plugins = {
            specializations = {},
        }
    }

    function Hekili:GetOptions()
        self:EmbedToggleOptions( Options )

        --[[ self:EmbedDisplayOptions( Options )

        self:EmbedPackOptions( Options )

        self:EmbedAbilityOptions( Options )

        self:EmbedItemOptions( Options )

        self:EmbedSpecOptions( Options ) ]]

        self:EmbedSkeletonOptions( Options )

        self:EmbedErrorOptions( Options )

        Hekili.OptionsReady = false

        return Options
    end
end


function Hekili:TotalRefresh( noOptions )
    if Hekili.PLAYER_ENTERING_WORLD then
        self:SpecializationChanged()
        self:RestoreDefaults()
    end

    for i, queue in pairs( ns.queue ) do
        for j, _ in pairs( queue ) do
            ns.queue[ i ][ j ] = nil
        end
        ns.queue[ i ] = nil
    end

    callHook( "onInitialize" )

    for specID, spec in pairs( class.specs ) do
        if specID > 0 then
            local options = self.DB.profile.specs[ specID ]

            for k, v in pairs( spec.options ) do
                if rawget( options, k ) == nil then options[ k ] = v end
            end
        end
    end

    self:RunOneTimeFixes()
    ns.checkImports()

    -- self:LoadScripts()
    if Hekili.OptionsReady then
        if Hekili.Config then
            self:RefreshOptions()
            ACD:SelectGroup( "Hekili", "profiles" )
        else Hekili.OptionsReady = false end
    end

    self:BuildUI()
    self:OverrideBinds()

    if WeakAuras and WeakAuras.ScanEvents then
        for name, toggle in pairs( Hekili.DB.profile.toggles ) do
            WeakAuras.ScanEvents( "HEKILI_TOGGLE", name, toggle.value )
        end
    end

    if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
end


function Hekili:RefreshOptions()
    if not self.Options then return end

    self:EmbedDisplayOptions()
    self:EmbedPackOptions()
    self:EmbedSpecOptions()
    self:EmbedAbilityOptions()
    self:EmbedItemOptions()

    Hekili.OptionsReady = true

    -- Until I feel like making this better at managing memory.
    collectgarbage()
end


function Hekili:GetOption( info, input )
    local category, depth, option = info[1], #info, info[#info]
    local profile = Hekili.DB.profile

    if category == 'general' then
        return profile[ option ]

    elseif category == 'bindings' then

        if option:match( "TOGGLE" ) or option == "HEKILI_SNAPSHOT" then
            return select( 1, GetBindingKey( option ) )

        elseif option == 'Pause' then
            return self.Pause

        else
            return profile[ option ]

        end

    elseif category == 'displays' then

        -- This is a generic display option/function.
        if depth == 2 then
            return nil

            -- This is a display (or a hook).
        else
            local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
            local hookKey, hookID = info[3], tonumber( match( info[3] or "", "^P(%d+)" ) )
            local display = profile.displays[ dispID ]

            -- This is a specific display's settings.
            if depth == 3 or not hookID then

                if option == 'x' or option == 'y' then
                    return tostring( display[ option ] )

                elseif option == 'spellFlashColor' or option == 'iconBorderColor' then
                    if type( display[option] ) ~= 'table' then display[option] = { r = 1, g = 1, b = 1, a = 1 } end
                    return display[option].r, display[option].g, display[option].b, display[option].a

                elseif option == 'Copy To' or option == 'Import' then
                    return nil

                else
                    return display[ option ]

                end

                -- This is a priority hook.
            else
                local hook = display.Queues[ hookID ]

                if option == 'Move' then
                    return hookID

                else
                    return hook[ option ]

                end

            end

        end

    elseif category == 'actionLists' then

        -- This is a general action list option.
        if depth == 2 then
            return nil

        else
            local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
            local actKey, actID = info[3], tonumber( match( info[3], "^A(%d+)" ) )
            local list = listID and profile.actionLists[ listID ]

            -- This is a specific action list.
            if depth == 3 or not actID then
                return list[ option ]

                -- This is a specific action.
            elseif listID and actID then
                local action = list.Actions[ actID ]

                if option == 'ConsumableArgs' then option = 'Args' end

                if option == 'Move' then
                    return actID

                else
                    return action[ option ]

                end

            end

        end

    elseif category == "snapshots" then
        return profile[ option ]
    end

    ns.Error( "GetOption() - should never see." )

end


local getUniqueName = function( category, name )
    local numChecked, suffix, original = 0, 1, name

    while numChecked < #category do
        for i, instance in ipairs( category ) do
            if name == instance.Name then
                name = original .. ' (' .. suffix .. ')'
                suffix = suffix + 1
                numChecked = 0
            else
                numChecked = numChecked + 1
            end
        end
    end

    return name
end


function Hekili:SetOption( info, input, ... )
    local category, depth, option = info[1], #info, info[#info]
    local Rebuild, RebuildUI, RebuildScripts, RebuildOptions, RebuildCache, Select
    local profile = Hekili.DB.profile

    if category == 'general' then
        -- We'll preset the option here; works for most options.
        profile[ option ] = input

        if option == 'enabled' then
            if input then
                self:Enable()
                ACD:SelectGroup( "Hekili", "general" )
            else self:Disable() end

            self:UpdateDisplayVisibility()

            return

        elseif option == 'minimapIcon' then
            profile.iconStore.hide = input
            if input then
                LDBIcon:Hide( "Hekili" )
            else
                LDBIcon:Show( "Hekili" )
            end
        end

        -- General options do not need add'l handling.
        return

    elseif category == "snapshots" then
        profile[ option ] = input
    end

    if Rebuild then
        ns.refreshOptions()
        ns.loadScripts()
        QueueRebuildUI()
    else
        if RebuildOptions then ns.refreshOptions() end
        if RebuildScripts then ns.loadScripts() end
        if RebuildCache and not RebuildUI then self:UpdateDisplayVisibility() end
        if RebuildUI then QueueRebuildUI() end
    end

    if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end

    if Select then
        ACD:SelectGroup( "Hekili", category, info[2], Select )
    end
end


do
    local validCommands = {
        makedefaults = true,
        import = true,
        skeleton = true,
        recover = true,
        center = true,

        profile = true,
        set = true,
        enable = true,
        disable = true,
        move = true,
        unlock = true,
        lock = true,
        dotinfo = true,
    }

    local toggleToIndex = {
        cooldowns = 51,
        interrupts = 52,
        potions = 53,
        defensives = 54,
        covenants = 55,
        essences = 55,
        minorCDs = 55,
        custom1 = 56,
        custom2 = 57,
    }

    local indexToToggle = {
        [51] = { "cooldowns", "Cooldowns" },
        [52] = { "interrupts", "Interrupts" },
        [53] = { "potions", "Potions" },
        [54] = { "defensives", "Defensives" },
        [55] = { "essences", "Minor CDs" },
        [56] = { "custom1", "Custom #1" },
        [57] = { "custom2", "Custom #2" },
    }

    local toggleInstructions = {
        "on|r (to enable)",
        "off|r (to disable)",
        "|r (to toggle)",
    }

    local info = {}
    local priorities = {}

    local function countPriorities()
        wipe( priorities )

        local spec = state.spec.id

        for priority, data in pairs( Hekili.DB.profile.packs ) do
            if data.spec == spec then
                insert( priorities, priority )
            end
        end

        sort( priorities )

        return #priorities
    end

    function Hekili:CmdLine( input )
        if not input or input:trim() == "" or input:trim() == "skeleton" then
            if input:trim() == 'skeleton' then
                self:StartListeningForSkeleton()
                self:Print( "Addon will now gather specialization information.  Select all talents and use all abilities for best results." )
                self:Print( "See the Skeleton tab for more information. ")
                Hekili.Skeleton = ""
            end

            ns.StartConfiguration()
            return

        elseif input:trim() == "recover" then
            local defaults = self:GetDefaults()

            for k, v in pairs( self.DB.profile.displays ) do
                local default = defaults.profile.displays[ k ]
                if defaults.profile.displays[ k ] then
                    for key, value in pairs( default ) do
                        if type( value ) == "table" then v[ key ] = tableCopy( value )
                        else v[ key ] = value end

                        if type( value ) == "table" then
                            for innerKey, innerValue in pairs( value ) do
                                if v[ key ][ innerKey ] == nil then
                                    if type( innerValue ) == "table" then v[ key ][ innerKey ] = tableCopy( innerValue )
                                    else v[ key ][ innerKey ] = innerValue end
                                end
                            end
                        end
                    end

                    for key, value in pairs( self.DB.profile.displays["**"] ) do
                        if type( value ) == "table" then v[ key ] = tableCopy( value )
                        else v[ key ] = value end

                        if type( value ) == "table" then
                            for innerKey, innerValue in pairs( value ) do
                                if v[ key ][ innerKey ] == nil then
                                    if type( innerValue ) == "table" then v[ key ][ innerKey ] = tableCopy( innerValue )
                                    else v[ key ][ innerKey ] = innerValue end
                                end
                            end
                        end
                    end
                end
            end
            self:RestoreDefaults()
            self:RefreshOptions()
            self:BuildUI()
            self:Print( "Default displays and action lists restored." )
            return

        end

        if input then
            input = input:trim()
            local args = {}

            for arg in string.gmatch( input, "%S+" ) do
                insert( args, lower( arg ) )
            end

            if ( "set" ):match( "^" .. args[1] ) then
                local profile = Hekili.DB.profile
                local spec = profile.specs[ state.spec.id ]
                local prefs = spec.settings
                local settings = class.specs[ state.spec.id ].settings

                local index

                if args[2] then
                    if ( "target_swap" ):match( "^" .. args[2] ) or ( "swap" ):match( "^" .. args[2] ) or ( "cycle" ):match( "^" .. args[2] ) then
                        index = -1
                    elseif ( "mode" ):match( "^" .. args[2] ) then
                        index = -2
                    else
                        for i, setting in ipairs( settings ) do
                            if setting.name:match( "^" .. args[2] ) then
                                index = i
                                break
                            end
                        end

                        if not index then
                            -- Check toggles instead.
                            for toggle, num in pairs( toggleToIndex ) do
                                if toggle:match( "^" .. args[2] ) then
                                    index = num
                                    break
                                end
                            end
                        end
                    end
                end

                if #args == 1 or not index then
                    -- No arguments, list options.
                    local output = "Use |cFFFFD100/hekili set|r to adjust your specialization options via chat or macros.\n\nOptions for " .. state.spec.name .. " are:"

                    local hasToggle, hasNumber = false, false
                    local exToggle, exNumber

                    for i, setting in ipairs( settings ) do
                        if not setting.info.arg or setting.info.arg() then
                            if setting.info.type == "toggle" then
                                output = format( "%s\n - |cFFFFD100%s|r = %s|r (%s)", output, setting.name, prefs[ setting.name ] and "|cFF00FF00ON" or "|cFFFF0000OFF", type( setting.info.name ) == "function" and setting.info.name() or setting.info.name )
                                hasToggle = true
                                exToggle = setting.name
                            elseif setting.info.type == "range" then
                                output = format( "%s\n - |cFFFFD100%s|r = |cFF00FF00%.2f|r, min: %.2f, max: %.2f", output, setting.name, prefs[ setting.name ], ( setting.info.min and format( "%.2f", setting.info.min ) or "N/A" ), ( setting.info.max and format( "%.2f", setting.info.max ) or "N/A" ), settingName )
                                hasNumber = true
                                exNumber = setting.name
                            end
                        end
                    end

                    output = format( "%s\n - |cFFFFD100cycle|r, |cFFFFD100swap|r, or |cFFFFD100target_swap|r = %s|r (%s)", output, spec.cycle and "|cFF00FF00ON" or "|cFFFF0000OFF", "Recommend Target Swaps" )

                    output = format( "%s\n\nTo control your toggles (|cFFFFD100cooldowns|r, |cFFFFD100covenants|r, |cFFFFD100defensives|r, |cFFFFD100interrupts|r, |cFFFFD100potions|r, |cFFFFD100custom1|r, and |cFFFFD100custom2|r):\n" ..
                        " - Enable Cooldowns:  |cFFFFD100/hek set cooldowns on|r\n" ..
                        " - Disable Interrupts:  |cFFFFD100/hek set interupts off|r\n" ..
                        " - Toggle Defensives:  |cFFFFD100/hek set defensives|r", output )

                    output = format( "%s\n\nTo control your display mode (currently |cFFFFD100%s|r):\n - Toggle Mode:  |cFFFFD100/hek set mode|r\n - Set Mode:  |cFFFFD100/hek set mode aoe|r (or |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100dual|r, |cFFFFD100reactive|r)", output, self.DB.profile.toggles.mode.value or "unknown" )

                    if hasToggle then
                        output = format( "%s\n\nTo set a |cFFFFD100specialization toggle|r, use the following commands:\n" ..
                            " - Toggle On/Off:  |cFFFFD100/hek set %s|r\n" ..
                            " - Enable:  |cFFFFD100/hek set %s on|r\n" ..
                            " - Disable:  |cFFFFD100/hek set %s off|r\n" ..
                            " - Reset to Default:  |cFFFFD100/hek set %s default|r", output, exToggle, exToggle, exToggle, exToggle )
                    end

                    if hasNumber then
                        output = format( "%s\n\nTo set a |cFFFFD100number|r value, use the following commands:\n" ..
                            " - Set to #:  |cFFFFD100/hek set %s #|r\n" ..
                            " - Reset to Default:  |cFFFFD100/hek set %s default|r", output, exNumber, exNumber )
                    end

                    output = format( "%s\n\nTo select another priority, see |cFFFFD100/hekili priority|r.", output )

                    Hekili:Print( output )
                    return
                end

                local toggle = indexToToggle[ index ]

                if toggle then
                    local tab, text, to = toggle[ 1 ], toggle[ 2 ]

                    if args[3] then
                        if args[3] == "on" then to = true
                        elseif args[3] == "off" then to = false
                        elseif args[3] == "default" then to = false
                        else
                            Hekili:Print( format( "'%s' is not a valid option for |cFFFFD100%s|r.", args[3], text ) )
                            return
                        end
                    else
                        to = not profile.toggles[ tab ].value
                    end

                    Hekili:Print( format( "|cFFFFD100%s|r toggle set to %s.", text, ( to and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r" ) ) )

                    profile.toggles[ tab ].value = to

                    if WeakAuras and WeakAuras.ScanEvents then WeakAuras.ScanEvents( "HEKILI_TOGGLE", tab, to ) end
                    if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
                    return
                end

                -- Two or more arguments, we're setting (or querying).
                if index == -1 then
                    local to

                    if args[3] then
                        if args[3] == "on" then to = true
                        elseif args[3] == "off" then to = false
                        elseif args[3] == "default" then to = false
                        else
                            Hekili:Print( format( "'%s' is not a valid option for |cFFFFD100%s|r.", args[3] ) )
                            return
                        end
                    else
                        to = not spec.cycle
                    end

                    Hekili:Print( format( "Recommend Target Swaps set to %s.", ( to and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r" ) ) )

                    spec.cycle = to

                    Hekili:ForceUpdate( "CLI_TOGGLE" )
                    return
                elseif index == -2 then
                    if args[3] then
                        Hekili:SetMode( args[3] )
                        if WeakAuras and WeakAuras.ScanEvents then WeakAuras.ScanEvents( "HEKILI_TOGGLE", "mode", args[3] ) end
                        if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
                    else
                        Hekili:FireToggle( "mode" )
                    end
                    return
                end

                local setting = settings[ index ]
                if not setting then
                    Hekili:Print( "Not a valid option." )
                    return
                end

                local settingName = type( setting.info.name ) == "function" and setting.info.name() or setting.info.name

                if setting.info.type == "toggle" then
                    local to

                    if args[3] then
                        if args[3] == "on" then to = true
                        elseif args[3] == "off" then to = false
                        elseif args[3] == "default" then to = setting.default
                        else
                            Hekili:Print( format( "'%s' is not a valid option for |cFFFFD100%s|r.", args[3] ) )
                            return
                        end
                    else
                        to = not setting.info.get( info )
                    end

                    Hekili:Print( format( "%s set to %s.", settingName, ( to and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r" ) ) )

                    info[ 1 ] = setting.name
                    setting.info.set( info, to )

                    Hekili:ForceUpdate( "CLI_TOGGLE" )
                    return

                elseif setting.info.type == "range" then
                    local to

                    if args[3] == "default" then
                        to = setting.default
                    else
                        to = tonumber( args[3] )
                    end

                    if to and ( ( setting.info.min and to < setting.info.min ) or ( setting.info.max and to > setting.info.max ) ) then
                        Hekili:Print( format( "The value for %s must be between %s and %s.", args[2], ( setting.info.min and format( "%.2f", setting.info.min ) or "N/A" ), ( setting.info.max and format( "%.2f", setting.info.max ) or "N/A" ) ) )
                        return
                    end

                    if not to then
                        Hekili:Print( format( "You must provide a number value for %s (or default).", args[2] ) )
                        return
                    end

                    Hekili:Print( format( "%s set to |cFF00B4FF%.2f|r.", settingName, to ) )
                    prefs[ setting.name ] = to
                    Hekili:ForceUpdate( "CLI_NUMBER" )
                    return

                end


            elseif ( "profile" ):match( "^" .. args[1] ) then
                if not args[2] then
                    local output = "Use |cFFFFD100/hekili profile name|r to swap profiles via command-line or macro.\nValid profile |cFFFFD100name|rs are:"

                    for name, prof in ns.orderedPairs( Hekili.DB.profiles ) do
                        output = format( "%s\n - |cFFFFD100%s|r %s", output, name, Hekili.DB.profile == prof and "|cFF00FF00(current)|r" or "" )
                    end

                    output = format( "%s\nTo create a new profile, see |cFFFFD100/hekili|r > |cFFFFD100Profiles|r.", output )

                    Hekili:Print( output )
                    return
                end

                local profileName = input:match( "%s+(.+)$" )

                if not rawget( Hekili.DB.profiles, profileName ) then
                    local output = format( "'%s' is not a valid profile name.\nValid profile |cFFFFD100name|rs are:", profileName )

                    local count = 0

                    for name, prof in ns.orderedPairs( Hekili.DB.profiles ) do
                        count = count + 1
                        output = format( "%s\n - |cFFFFD100%s|r %s", output, name, Hekili.DB.profile == prof and "|cFF00FF00(current)|r" or "" )
                    end

                    output = format( "%s\n\nTo create a new profile, see |cFFFFD100/hekili|r > |cFFFFD100Profiles|r.", output )

                    Hekili:Notify( output )
                    return
                end

                Hekili:Print( format( "Set profile to |cFF00FF00%s|r.", profileName ) )
                self.DB:SetProfile( profileName )
                return

            elseif ( "priority" ):match( "^" .. args[1] ) then
                local n = countPriorities()

                if not args[2] then
                    local output = "Use |cFFFFD100/hekili priority name|r to change your current specialization's priority via command-line or macro."

                    if n < 2 then
                        output = output .. "\n\n|cFFFF0000You must have multiple priorities for your specialization to use this feature.|r"
                    else
                        output = output .. "\nValid priority |cFFFFD100name|rs are:"
                        for i, priority in ipairs( priorities ) do
                            output = format( "%s\n - %s%s|r %s", output, Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, Hekili.DB.profile.specs[ state.spec.id ].package == priority and "|cFF00FF00(current)|r" or "" )
                        end
                    end

                    output = format( "%s\n\nTo create a new priority, see |cFFFFD100/hekili|r > |cFFFFD100Priorities|r.", output )

                    if Hekili.DB.profile.notifications.enabled then Hekili:Notify( output ) end
                    Hekili:Print( output )
                    return
                end

                -- Setting priority via commandline.
                -- Requires multiple priorities loaded for one's specialization.
                -- This also prepares the priorities table with relevant priority names.

                if n < 2 then
                    Hekili:Print( "You must have multiple priorities for your specialization to use this feature." )
                    return
                end

                if not args[2] then
                    local output = "You must provide the priority name (case sensitive).\nValid options are"
                    for i, priority in ipairs( priorities ) do
                        output = output .. format( " %s%s|r%s", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, i == #priorities and "." or "," )
                    end
                    Hekili:Print( output )
                    return
                end

                local raw = input:match( "^%S+%s+(.+)$" )
                local name = raw:gsub( "%%", "%%%%" ):gsub( "^%^", "%%^" ):gsub( "%$$", "%%$" ):gsub( "%(", "%%(" ):gsub( "%)", "%%)" ):gsub( "%.", "%%." ):gsub( "%[", "%%[" ):gsub( "%]", "%%]" ):gsub( "%*", "%%*" ):gsub( "%+", "%%+" ):gsub( "%-", "%%-" ):gsub( "%?", "%%?" )

                for i, priority in ipairs( priorities ) do
                    if priority:match( "^" .. name ) then
                        Hekili.DB.profile.specs[ state.spec.id ].package = priority
                        local output = format( "Priority set to %s%s|r.", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority )
                        if Hekili.DB.profile.notifications.enabled then Hekili:Notify( output ) end
                        Hekili:Print( output )
                        Hekili:ForceUpdate( "CLI_TOGGLE" )
                        return
                    end
                end

                local output = format( "No match found for priority '%s'.\nValid options are", raw )

                for i, priority in ipairs( priorities ) do
                    output = output .. format( " %s%s|r%s", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, i == #priorities and "." or "," )
                end

                if Hekili.DB.profile.notifications.enabled then Hekili:Notify( output ) end
                Hekili:Print( output )
                return

            elseif ( "enable" ):match( "^" .. args[1] ) or ( "disable" ):match( "^" .. args[1] ) then
                local enable = ( "enable" ):match( "^" .. args[1] ) or false

                for i, buttons in ipairs( ns.UI.Buttons ) do
                    for j, _ in ipairs( buttons ) do
                        if not enable then
                            buttons[j]:Hide()
                        else
                            buttons[j]:Show()
                        end
                    end
                end

                self.DB.profile.enabled = enable

                if enable then
                    Hekili:Print( "Addon |cFFFFD100ENABLED|r." )
                    self:Enable()
                else
                    Hekili:Print( "Addon |cFFFFD100DISABLED|r." )
                    self:Disable()
                end

            elseif ( "move" ):match( "^" .. args[1] ) or ( "unlock" ):match( "^" .. args[1] ) then
                if InCombatLockdown() then
                    Hekili:Print( "Movers cannot be activated while in combat." )
                    return
                end

                if not Hekili.Config then
                    ns.StartConfiguration( true )
                elseif ( "move" ):match( "^" .. args[1] ) and Hekili.Config then
                    ns.StopConfiguration()
                end

            elseif ("stress" ):match( "^" .. args[1] ) then
                if InCombatLockdown() then
                    Hekili:Print( "Unable to stress test abilities and auras while in combat." )
                    return
                end

                local precount = 0
                for k, v in pairs( self.ErrorDB ) do
                    precount = precount + v.n
                end

                local results, count, specs = "", 0, {}
                for i in ipairs( class.specs ) do
                    if i ~= 0 then insert( specs, i ) end
                end
                sort( specs )

                for i, specID in ipairs( specs ) do
                    local spec = class.specs[ specID ]
                    results = format( "%sSpecialization: %s\n", results, spec.name )

                    for key, aura in ipairs( spec.auras ) do
                        local keyNamed = false
                        -- Avoid duplicates.
                        if aura.key == key then
                            for k, v in pairs( aura ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Aura: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                            for k, v in pairs( aura.funcs ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Aura: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end

                    for key, ability in ipairs( spec.abilities ) do
                        local keyNamed = false
                        -- Avoid duplicates.
                        if ability.key == key then
                            for k, v in pairs( ability ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Ability: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                            for k, v in pairs( ability.funcs ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Ability: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end
                end

                local postcount = 0
                for k, v in pairs( self.ErrorDB ) do
                    postcount = postcount + v.n
                end

                if count > 0 then
                    Hekili:Print( results )
                    Hekili:Error( results )
                end

                if postcount > precount then Hekili:Print( "New warnings were loaded in /hekili > Warnings." ) end
                if count == 0 and postcount == precount then Hekili:Print( "Stress test completed; no issues found." ) end

            elseif ( "lock" ):match( "^" .. args[1] ) then
                if Hekili.Config then
                    ns.StopConfiguration()
                else
                    Hekili:Print( "Displays are not unlocked.  Use |cFFFFD100/hek move|r or |cFFFFD100/hek unlock|r to allow click-and-drag." )
                end
            elseif ( "dotinfo" ):match( "^" .. args[1] ) then
                local aura = args[2] and args[2]:trim()
                Hekili:DumpDotInfo( aura )
            end
        else
            LibStub( "AceConfigCmd-3.0" ):HandleCommand( "hekili", "Hekili", input )
        end
    end
end


-- Import/Export
-- Nicer string encoding from WeakAuras, thanks to Stanzilla.

local bit_band, bit_lshift, bit_rshift = bit.band, bit.lshift, bit.rshift
local string_char = string.char

local bytetoB64 = {
    [0]="a","b","c","d","e","f","g","h",
    "i","j","k","l","m","n","o","p",
    "q","r","s","t","u","v","w","x",
    "y","z","A","B","C","D","E","F",
    "G","H","I","J","K","L","M","N",
    "O","P","Q","R","S","T","U","V",
    "W","X","Y","Z","0","1","2","3",
    "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
    a = 0, b = 1, c = 2, d = 3, e = 4, f = 5, g = 6, h = 7,
    i = 8, j = 9, k = 10, l = 11, m = 12, n = 13, o = 14, p = 15,
    q = 16, r = 17, s = 18, t = 19, u = 20, v = 21, w = 22, x = 23,
    y = 24, z = 25, A = 26, B = 27, C = 28, D = 29, E = 30, F = 31,
    G = 32, H = 33, I = 34, J = 35, K = 36, L = 37, M = 38, N = 39,
    O = 40, P = 41, Q = 42, R = 43, S = 44, T = 45, U = 46, V = 47,
    W = 48, X = 49, Y = 50, Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
    ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

-- This code is based on the Encode7Bit algorithm from LibCompress
-- Credit goes to Galmok (galmok@gmail.com)
local encodeB64Table = {};

local function encodeB64(str)
    local B64 = encodeB64Table;
    local remainder = 0;
    local remainder_length = 0;
    local encoded_size = 0;
    local l=#str
    local code
    for i=1,l do
        code = string.byte(str, i);
        remainder = remainder + bit_lshift(code, remainder_length);
        remainder_length = remainder_length + 8;
        while(remainder_length) >= 6 do
            encoded_size = encoded_size + 1;
            B64[encoded_size] = bytetoB64[bit_band(remainder, 63)];
            remainder = bit_rshift(remainder, 6);
            remainder_length = remainder_length - 6;
        end
    end
    if remainder_length > 0 then
        encoded_size = encoded_size + 1;
        B64[encoded_size] = bytetoB64[remainder];
    end
    return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}

local function decodeB64(str)
    local bit8 = decodeB64Table;
    local decoded_size = 0;
    local ch;
    local i = 1;
    local bitfield_len = 0;
    local bitfield = 0;
    local l = #str;
    while true do
        if bitfield_len >= 8 then
            decoded_size = decoded_size + 1;
            bit8[decoded_size] = string_char(bit_band(bitfield, 255));
            bitfield = bit_rshift(bitfield, 8);
            bitfield_len = bitfield_len - 8;
        end
        ch = B64tobyte[str:sub(i, i)];
        bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
        bitfield_len = bitfield_len + 6;
        if i > l then
            break;
        end
        i = i + 1;
    end
    return table.concat(bit8, "", 1, decoded_size)
end


-- Import/Export Strings
local Compresser = LibStub:GetLibrary("LibCompress")
local Encoder = Compresser:GetChatEncodeTable()

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local ldConfig = { level = 5 }

local Serializer = LibStub:GetLibrary("AceSerializer-3.0")


TableToString = function( inTable, forChat )
    local serialized = Serializer:Serialize( inTable )
    local compressed = LibDeflate:CompressDeflate( serialized, ldConfig )

    return format( "Hekili:%s", forChat and ( LibDeflate:EncodeForPrint( compressed ) ) or ( LibDeflate:EncodeForWoWAddonChannel( compressed ) ) )
end


StringToTable = function( inString, fromChat )
    local modern = false
    if inString:sub( 1, 7 ) == "Hekili:" then
        modern = true
        inString = inString:sub( 8 )
    end

    local decoded, decompressed, errorMsg

    if modern then
        decoded = fromChat and LibDeflate:DecodeForPrint(inString) or LibDeflate:DecodeForWoWAddonChannel(inString)
        if not decoded then return "Unable to decode." end

        decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then return "Unable to decompress decoded string." end
    else
        decoded = fromChat and decodeB64(inString) or Encoder:Decode(inString)
        if not decoded then return "Unable to decode." end

        decompressed, errorMsg = Compresser:Decompress(decoded);
        if not decompressed then return "Unable to decompress decoded string: " .. errorMsg end
    end

    local success, deserialized = Serializer:Deserialize(decompressed);
    if not success then return "Unable to deserialized decompressed string: " .. deserialized end

    return deserialized
end


SerializeDisplay = function( display )
    local serial = rawget( Hekili.DB.profile.displays, display )
    if not serial then return end

    return TableToString( serial, true )
end


DeserializeDisplay = function( str )
    local display = StringToTable( str, true )
    return display
end


SerializeActionPack = function( name )
    local pack = rawget( Hekili.DB.profile.packs, name )
    if not pack then return end

    local serial = {
        type = "package",
        name = name,
        date = tonumber( date("%Y%m%d.%H%M%S") ),
        payload = tableCopy( pack )
    }

    serial.payload.builtIn = false

    return TableToString( serial, true )
end


DeserializeActionPack = function( str )
    local serial = StringToTable( str, true )

    if not serial or type( serial ) == "string" or serial.type ~= "package" then
        return serial or "Unable to restore Priority from the provided string."
    end

    serial.payload.builtIn = false

    return serial
end
Hekili.DeserializeActionPack = DeserializeActionPack


SerializeStyle = function( ... )
    local serial = {
        type = "style",
        date = tonumber( date("%Y%m%d.%H%M%S") ),
        payload = {}
    }

    local hasPayload = false

    for i = 1, select( "#", ... ) do
        local dispName = select( i, ... )
        local display = rawget( Hekili.DB.profile.displays, dispName )

        if not display then return "Attempted to serialize an invalid display (" .. dispName .. ")" end

        serial.payload[ dispName ] = tableCopy( display )
        hasPayload = true
    end

    if not hasPayload then return "No displays selected to export." end
    return TableToString( serial, true )
end


DeserializeStyle = function( str )
    local serial = StringToTable( str, true )

    if not serial or type( serial ) == 'string' or not serial.type == "style" then
        return nil, serial
    end

    return serial.payload
end

-- End Import/Export Strings


local Sanitize

-- Begin APL Parsing
do
    local ignore_actions = {
        snapshot_stats = 1,
        flask = 1,
        food = 1,
        augmentation = 1
    }

    local expressions = {
        { "stealthed"                                       , "stealthed.rogue"                         },
        { "rtb_buffs%.normal"                               , "rtb_buffs_normal"                        },
        { "rtb_buffs%.min_remains"                          , "rtb_buffs_min_remains"                   },
        { "rtb_buffs%.max_remains"                          , "rtb_buffs_max_remains"                   },
        { "rtb_buffs%.shorter"                              , "rtb_buffs_shorter"                       },
        { "rtb_buffs%.longer"                               , "rtb_buffs_longer"                        },
        { "rtb_buffs%.will_lose%.([%w_]+)"                  , "rtb_buffs_will_lose_buff.%1"             },
        { "rtb_buffs%.will_lose"                            , "rtb_buffs_will_lose"                     },
        { "rtb_buffs%.total"                                , "rtb_buffs"                               },
        { "hyperthread_wristwraps%.([%w_]+)%.first_remains" , "hyperthread_wristwraps.first_remains.%1" },
        { "hyperthread_wristwraps%.([%w_]+)%.count"         , "hyperthread_wristwraps.%1"               },
        { "cooldown"                                        , "action_cooldown"                         },
        { "covenant%.([%w_]+)%.enabled"                     , "covenant.%1"                             },
        { "talent%.([%w_]+)"                                , "talent.%1.enabled"                       },
        { "legendary%.([%w_]+)"                             , "legendary.%1.enabled"                    },
        { "runeforge%.([%w_]+)"                             , "runeforge.%1.enabled"                    },
        { "rune_word%.([%w_]+)"                             , "buff.rune_word_%1.up"                    },
        { "rune_word%.([%w_]+)%.enabled"                    , "buff.rune_word_%1.up"                    },
        { "conduit%.([%w_]+)"                               , "conduit.%1.enabled"                      },
        { "soulbind%.([%w_]+)"                              , "soulbind.%1.enabled"                     },
        { "pet.[%w_]+%.([%w_]+)%.([%w%._]+)"                , "%1.%2"                                   },
        { "essence%.([%w_]+).rank(%d)"                      , "essence.%1.rank>=%2"                     },
        { "target%.1%.time_to_die"                          , "time_to_die"                             },
        { "time_to_pct_(%d+)%.remains"                      , "time_to_pct_%1"                          },
        { "trinket%.(%d)%.([%w%._]+)"                       , "trinket.t%1.%2"                          },
        { "trinket%.([%w_]+)%.cooldown"                     , "trinket.%1.cooldown.duration"            },
        { "trinket%.([%w_]+)%.proc%.([%w_]+)%.duration"     , "trinket.%1.buff_duration"                },
        { "trinket%.([%w_]+)%.buff%.duration"               , "trinket.%1.buff_duration"                },
        { "trinket%.([%w_]+)%.proc%.([%w_]+)%.[%w_]+"       , "trinket.%1.has_use_buff"                 },
        { "trinket%.([%w_]+)%.has_buff%.([%w_]+)"           , "trinket.%1.has_use_buff"                 },
        { "trinket%.([%w_]+)%.has_use_buff%.([%w_]+)"       , "trinket.%1.has_use_buff"                 },
        { "min:([%w_]+)"                                    , "%1"                                      },
        { "position_back"                                   , "true"                                    },
        { "max:(%w_]+)"                                     , "%1"                                      },
        { "incanters_flow_time_to%.(%d+)"                   , "incanters_flow_time_to_%.%1.any"         },
        { "exsanguinated%.([%w_]+)"                         , "debuff.%1.exsanguinated"                 },
        { "time_to_sht%.(%d+)%.plus"                        , "time_to_sht_plus.%1"                     },
        { "target"                                          , "target.unit"                             },
        { "player"                                          , "player.unit"                             },
        { "gcd"                                             , "gcd.max"                                 },

        { "equipped%.(%d+)", nil, function( item )
            item = tonumber( item )

            if not item then return "equipped.none" end

            if class.abilities[ item ] then
                return "equipped." .. ( class.abilities[ item ].key or "none" )
            end

            return "equipped[" .. item .. "]"
        end },

        { "trinket%.([%w_]+)%.cooldown%.([%w_]+)", nil, function( trinket, token )
            if class.abilities[ trinket ] then
                return "cooldown." .. trinket .. "." .. token
            end

            return "trinket." .. trinket .. ".cooldown." .. token
        end,  },

    }

    local operations = {
        { "=="  , "="  },
        { "%%"  , "/"  },
        { "//"  , "%%" }
    }


    function Hekili:AddSanitizeExpr( from, to, func )
        insert( expressions, { from, to, func } )
    end

    function Hekili:AddSanitizeOper( from, to )
        insert( operations, { from, to } )
    end

    Sanitize = function( segment, i, line, warnings )
        if i == nil then return end

        local operators = {
            [">"] = true,
            ["<"] = true,
            ["="] = true,
            ["~"] = true,
            ["+"] = true,
            ["-"] = true,
            ["%%"] = true,
            ["*"] = true
        }

        local maths = {
            ['+'] = true,
            ['-'] = true,
            ['*'] = true,
            ['%%'] = true
        }

        local times = 0
        local output, pre = "", ""

        for op1, token, op2 in gmatch( i, "([^%w%._ ]*)([%w%._]+)([^%w%._ ]*)" ) do
            --[[ if op1 and op1:len() > 0 then
                pre = op1
                for _, subs in ipairs( operations ) do
                    op1, times = op1:gsub( subs[1], subs[2] )

                    if times > 0 then
                        insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. op1 .. "' (" ..times .. "x)." )
                    end
                end
            end ]]

            if token and token:len() > 0 then
                pre = token
                for _, subs in ipairs( expressions ) do
                    if subs[2] then
                        times = 0
                        local s1, s2, s3, s4, s5 = token:match( "^" .. subs[1] .. "$" )
                        if s1 then
                            token = subs[2]
                            token, times = token:gsub( "%%1", s1 )

                            if s2 then token = token:gsub( "%%2", s2 ) end
                            if s3 then token = token:gsub( "%%3", s3 ) end
                            if s4 then token = token:gsub( "%%4", s4 ) end
                            if s5 then token = token:gsub( "%%5", s5 ) end

                            if times > 0 then
                                insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. token .. "' (" .. times .. "x)." )
                            end
                        end
                    elseif subs[3] then
                        local val, v2, v3, v4, v5 = token:match( "^" .. subs[1] .. "$" )
                        if val ~= nil then
                            token = subs[3]( val, v2, v3, v4, v5 )
                            insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. token .. "'." )
                        end
                    end
                end
            end

            --[[
            if op2 and op2:len() > 0 then
                for _, subs in ipairs( operations ) do
                    op2, times = op2:gsub( subs[1], subs[2] )
                    if times > 0 then
                        insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. op2 .. "' (" ..times .. "x)." )
                    end
                end
            end ]]

            output = output .. ( op1 or "" ) .. ( token or "" ) .. ( op2 or "" )
        end

        local ops_swapped = false
        pre = output

        -- Replace operators after its been stitched back together.
        for _, subs in ipairs( operations ) do
            output, times = output:gsub( subs[1], subs[2] )
            if times > 0 then
                ops_swapped = true
            end
        end

        if ops_swapped then
            insert( warnings, "Line " .. line .. ": Converted operations in '" .. pre .. "' to '" .. output .. "'." )
        end

        return output
    end

    local function strsplit( str, delimiter )
        local result = {}
        local from = 1

        if not delimiter or delimiter == "" then
            result[1] = str
            return result
        end

        local delim_from, delim_to = string.find( str, delimiter, from )

        while delim_from do
            insert( result, string.sub( str, from, delim_from - 1 ) )
            from = delim_to + 1
            delim_from, delim_to = string.find( str, delimiter, from )
        end

        insert( result, string.sub( str, from ) )
        return result
    end

    local parseData = {
        warnings = {},
        missing = {},
    }

    local nameMap = {
        call_action_list = "list_name",
        run_action_list = "list_name",
        variable = "var_name",
        cancel_action = "action_name",
        cancel_buff = "buff_name",
        op = "op",
    }

    function Hekili:ParseActionList( list )
        local line, times = 0, 0
        local output, warnings, missing = {}, parseData.warnings, parseData.missing

        wipe( warnings )
        wipe( missing )

        list = list:gsub( "(|)([^|])", "%1|%2" ):gsub( "|||", "||" )

        local n = 0
        for aura in list:gmatch( "buff%.([a-zA-Z0-9_]+)" ) do
            if not class.auras[ aura ] then
                missing[ aura ] = true
                n = n + 1
            end
        end

        for aura in list:gmatch( "active_dot%.([a-zA-Z0-9_]+)" ) do
            if not class.auras[ aura ] then
                missing[ aura ] = true
                n = n + 1
            end
        end

        -- TODO: Revise to start from beginning of string.
        for i in list:gmatch( "action.-=/?([^\n^$]*)") do
            line = line + 1

            if i:sub(1, 3) == 'jab' then
                for token in i:gmatch( 'cooldown%.expel_harm%.remains>=gcd' ) do

                    local times = 0
                    while (i:find(token)) do
                        local strpos, strend = i:find(token)

                        local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                        local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                        local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                        local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                        local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                        i = start .. repl .. finish
                        times = times + 1
                    end
                    insert( warnings, "Line " .. line .. ": Removed unnecessary expel_harm cooldown check from action entry for jab (" .. times .. "x)." )
                end
            end

            --[[ for token in i:gmatch( 'spell_targets[.%a_]-' ) do

                local times = 0
                while (i:find(token)) do
                    local strpos, strend = i:find(token)

                    local start = strpos > 2 and i:sub( 1, strpos - 1 ) or ''
                    local finish = strend < i:len() - 1 and i:sub( strend + 1 ) or ''

                    i = start .. enemies .. finish
                    times = times + 1
                end
                insert( warnings, "Line " .. line .. ": Replaced unsupported '" .. token .. "' with '" .. enemies .. "' (" .. times .. "x)." )
            end ]]

            if i:sub(1, 13) == 'fists_of_fury' then
                for token in i:gmatch( "energy.time_to_max>cast_time" ) do
                    local times = 0
                    while (i:find(token)) do
                        local strpos, strend = i:find(token)

                        local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                        local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                        local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                        local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                        local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                        i = start .. repl .. finish
                        times = times + 1
                    end
                    insert( warnings, "Line " .. line .. ": Removed unnecessary energy cap check from action entry for fists_of_fury (" .. times .. "x)." )
                end
            end

            local components = strsplit( i, "," )
            local result = {}

            for a, str in ipairs( components ) do
                -- First element is the action, if supported.
                if a == 1 then
                    local ability = str:trim()

                    if ability and ( ability == "use_item" or class.abilities[ ability ] ) then
                        if ability == "pocketsized_computation_device" then ability = "cyclotronic_blast" end
                        -- Stub abilities that are replaced sometimes.
                        if ability == "any_dnd" or ability == "wound_spender" or ability == "summon_pet" or ability == "apply_poison" then
                            result.action = ability
                        else
                            result.action = class.abilities[ ability ] and class.abilities[ ability ].key or ability
                        end
                    elseif not ignore_actions[ ability ] then
                        insert( warnings, "Line " .. line .. ": Unsupported action '" .. ability .. "'." )
                        result.action = ability
                    end

                else
                    local key, value = str:match( "^(.-)=(.-)$" )

                    if key and value then
                        -- TODO:  Automerge multiple criteria.
                        if key == 'if' or key == 'condition' then key = 'criteria' end

                        if key == 'criteria' or key == 'target_if' or key == 'value' or key == 'value_else' or key == 'sec' or key == 'wait' then
                            value = Sanitize( 'c', value, line, warnings )
                            value = SpaceOut( value )
                        end

                        if key == 'description' then
                            value = value:gsub( ";", "," )
                        end

                        result[ key ] = value
                    end
                end
            end

            if nameMap[ result.action ] then
                result[ nameMap[ result.action ] ] = result.name
                result.name = nil
            end

            if result.target_if then result.target_if = result.target_if:gsub( "min:", "" ):gsub( "max:", "" ) end

            -- As of 11/11/2022 (11/11/2022 in Europe), empower_to is purely a number 1-4.
            if result.empower_to and ( result.empower_to == "max" or result.empower_to == "maximum" ) then result.empower_to = "max_empower" end
            if result.for_next then result.for_next = tonumber( result.for_next ) end
            if result.cycle_targets then result.cycle_targets = tonumber( result.cycle_targets ) end
            if result.max_energy then result.max_energy = tonumber( result.max_energy ) end

            if result.use_off_gcd then result.use_off_gcd = tonumber( result.use_off_gcd ) end
            if result.use_while_casting then result.use_while_casting = tonumber( result.use_while_casting ) end
            if result.strict then result.strict = tonumber( result.strict ) end
            if result.moving then result.enable_moving = true; result.moving = tonumber( result.moving ) end

            if result.target_if and not result.criteria then
                result.criteria = result.target_if
                result.target_if = nil
            end

            if result.action == "use_item" then
                if result.effect_name and class.abilities[ result.effect_name ] then
                    result.action = class.abilities[ result.effect_name ].key
                elseif result.name and class.abilities[ result.name ] then
                    result.action = result.name
                elseif ( result.slot or result.slots ) and class.abilities[ result.slot or result.slots ] then
                    result.action = result.slot or result.slots
                end

                if result.action == "use_item" then
                    insert( warnings, "Line " .. line .. ": Unsupported use_item action [ " .. ( result.effect_name or result.name or "unknown" ) .. "]; entry disabled." )
                    result.action = nil
                    result.enabled = false
                end
            end

            if result.action == "wait_for_cooldown" then
                if result.name then
                    result.action = "wait"
                    result.sec = "cooldown." .. result.name .. ".remains"
                    result.name = nil
                else
                    insert( warnings, "Line " .. line .. ": Unable to convert wait_for_cooldown,name=X to wait,sec=cooldown.X.remains; entry disabled." )
                    result.action = "wait"
                    result.enabled = false
                end
            end

            if result.action == 'use_items' and ( result.slot or result.slots ) then
                result.action = result.slot or result.slots
            end

            if result.action == 'variable' and not result.op then
                result.op = 'set'
            end

            if result.cancel_if and not result.interrupt_if then
                result.interrupt_if = result.cancel_if
                result.cancel_if = nil
            end

            insert( output, result )
        end

        if n > 0 then
            insert( warnings, "The following auras were used in the action list but were not found in the addon database:" )
            for k in orderedPairs( missing ) do
                insert( warnings, " - " .. k )
            end
        end

        return #output > 0 and output or nil, #warnings > 0 and warnings or nil
    end
end

-- End APL Parsing


local warnOnce = false

-- Begin Toggles
function Hekili:TogglePause( ... )

    Hekili.btns = ns.UI.Buttons

    if not self.Pause then
        self:MakeSnapshot()
        self.Pause = true

        --[[ if self:SaveDebugSnapshot() then
            if not warnOnce then
                self:Print( "Snapshot saved; snapshots are viewable via /hekili (until you reload your UI)." )
                warnOnce = true
            else
                self:Print( "Snapshot saved." )
            end
        end ]]

    else
        self.Pause = false
        self.ActiveDebug = false

        -- Discard the active update thread so we'll definitely start fresh at next update.
        Hekili:ForceUpdate( "TOGGLE_PAUSE", true )
    end

    local MouseInteract = self.Pause or self.Config

    for _, group in pairs( ns.UI.Buttons ) do
        for _, button in pairs( group ) do
            if button:IsShown() then
                button:EnableMouse( MouseInteract )
            end
        end
    end

    self:Print( ( not self.Pause and "UN" or "" ) .. "PAUSED." )
    if Hekili.DB.profile.notifications.enabled then self:Notify( ( not self.Pause and "UN" or "" ) .. "PAUSED" ) end

end


-- Key Bindings
function Hekili:MakeSnapshot( isAuto )
    if isAuto and not Hekili.DB.profile.autoSnapshot then
        return
    end

    self.ActiveDebug = true
    Hekili.Update()
    self.ActiveDebug = false

    HekiliDisplayPrimary.activeThread = nil
end



function Hekili:Notify( str, duration )
    if not self.DB.profile.notifications.enabled then
        self:Print( str )
        return
    end

    HekiliNotificationText:SetText( str )
    HekiliNotificationText:SetTextColor( 1, 0.8, 0, 1 )
    UIFrameFadeOut( HekiliNotificationText, duration or 3, 1, 0 )
end


do
    local modes = {
        "automatic", "single", "aoe", "dual", "reactive"
    }

    local modeIndex = {
        automatic = { 1, "Automatic" },
        single = { 2, "Single-Target" },
        aoe = { 3, "AOE (Multi-Target)" },
        dual = { 4, "Fixed Dual" },
        reactive = { 5, "Reactive Dual" },
    }

    local toggles = setmetatable( {
        custom1 = "Custom #1",
        custom2 = "Custom #2",
    }, {
        __index = function( t, k )
            if k == "essences" then k = "covenants" end

            local name = k:gsub( "^(.)", strupper )
            t[k] = name
            return name
        end,
    } )


    function Hekili:SetMode( mode )
        mode = lower( mode:trim() )

        if not modeIndex[ mode ] then
            Hekili:Print( "SetMode failed:  '%s' is not a valid mode.\nTry |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100aoe|r, |cFFFFD100dual|r, or |cFFFFD100reactive|r." )
            return
        end

        self.DB.profile.toggles.mode.value = mode

        if self.DB.profile.notifications.enabled then
            self:Notify( "Mode: " .. modeIndex[ mode ][2] )
        else
            self:Print( modeIndex[ mode ][2] .. " mode activated." )
        end
    end


    function Hekili:FireToggle( name )
        local toggle = name and self.DB.profile.toggles[ name ]

        if not toggle then return end

        if name == 'mode' then
            local current = toggle.value
            local c_index = modeIndex[ current ][ 1 ]

            local i = c_index + 1

            while true do
                if i > #modes then i = i % #modes end
                if i == c_index then break end

                local newMode = modes[ i ]

                if toggle[ newMode ] then
                    toggle.value = newMode
                    break
                end

                i = i + 1
            end

            if self.DB.profile.notifications.enabled then
                self:Notify( "Mode: " .. modeIndex[ toggle.value ][2] )
            else
                self:Print( modeIndex[ toggle.value ][2] .. " mode activated." )
            end

        elseif name == 'pause' then
            self:TogglePause()
            return

        elseif name == 'snapshot' then
            self:MakeSnapshot()
            return

        else
            toggle.value = not toggle.value

            if toggle.name then toggles[ name ] = toggle.name end

            if self.DB.profile.notifications.enabled then
                self:Notify( toggles[ name ] .. ": " .. ( toggle.value and "ON" or "OFF" ) )
            else
                self:Print( toggles[ name ].. ( toggle.value and " |cFF00FF00ENABLED|r." or " |cFFFF0000DISABLED|r." ) )
            end
        end

        if WeakAuras and WeakAuras.ScanEvents then WeakAuras.ScanEvents( "HEKILI_TOGGLE", name, toggle.value ) end
        if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
        self:UpdateDisplayVisibility()

        self:ForceUpdate( "HEKILI_TOGGLE", true )
    end


    function Hekili:GetToggleState( name, class )
        local t = name and self.DB.profile.toggles[ name ]

        return t and t.value
    end
end

-- End Toggles
