local addonName, addon = ...
local addonPath = "Interface\\AddOns\\" .. addonName

addon.Constants = addon.Constants or {}
local C = addon.Constants

C.Addon = {
    Name = addonName,
    AceName = "MinimalistCooldownEdge",
    ShortName = "MiniCE",
    SavedVariables = "MinimalistCooldownEdgeDB_v2",
    MiniCCName = "MiniCC",
    SArenaName = "sArena_Reloaded",
    TellMeWhenName = "TellMeWhen",
    ShinyAurasName = "ShinyAuras",
    VersionFallback = "Dev",
    SlashCommands = { "mce", "minice", "minimalistcooldownedge" },
}

C.Assets = {
    Root = addonPath,
    Icon = addonPath .. "\\Assets\\Textures\\MinimalistCooldownEdge",
}

C.Categories = {
    Actionbar = "actionbar",
    Nameplate = "nameplate",
    Unitframe = "unitframe",
    CooldownManager = "cooldownmanager",
    MiniCC = "minicc",
    SArena = "sarena",
    TellMeWhen = "tellmewhen",
    Blacklist = "blacklist",
    AuraPending = "aura_pending",
    CompactPartyAura = "compactPartyAura",
}

C.CooldownManagerViewers = {
    Essential = "essential",
    Utility = "utility",
    BuffIcon = "bufficon",
    UtilityOrEssential = "utility_or_essential",
}

C.MiniCCFrameTypes = {
    CC = "cc",
    Nameplate = "nameplate",
    Portrait = "portrait",
    Overlay = "overlay",
}

C.SArenaFrameTypes = {
    ClassIcon = "classicon",
    DR = "dr",
    Trinket = "trinket",
    Racial = "racial",
}

C.GroupFrameTypes = {
    Party = "party",
    Raid = "raid",
}

C.Chat = {
    Prefix = "|cff00ccffMiniCE|r",
}

C.Options = {
    SliderDebounceDelay = 0.15,
    FrameWidth = 900,
    FrameHeight = 600,
    TreeWidth = 210,
    DefaultAbbrevThreshold = 90,
}

C.Style = {
    Fonts = {
        GameDefault = "GAMEDEFAULT",
        FrizQuadrata = "Fonts\\FRIZQT__.TTF",
        FrizQuadrataCyrillic = "Fonts\\FRIZQT___CYR.TTF",
        ArialNarrow = "Fonts\\ARIALN.TTF",
        Morpheus = "Fonts\\MORPHEUS.TTF",
        Skurri = "Fonts\\skurri.ttf",
        TwoThousandTwo = "Fonts\\2002.TTF",
        Expressway = addonPath .. "\\Assets\\Fonts\\expressway.ttf",
        Bazooka = addonPath .. "\\Assets\\Fonts\\bazooka_regular.ttf",
    },
    FontStyles = {
        None = "NONE",
        Outline = "OUTLINE",
        ThickOutline = "THICKOUTLINE",
        Monochrome = "MONOCHROME",
    },
    Anchors = {
        Center = "CENTER",
        TopLeft = "TOPLEFT",
        TopRight = "TOPRIGHT",
        BottomLeft = "BOTTOMLEFT",
        BottomRight = "BOTTOMRIGHT",
    },
    Layers = {
        Overlay = "OVERLAY",
    },
}

C.FontOptionsBase = {
    [C.Style.Fonts.GameDefault] = "Game Default",
    [C.Style.Fonts.FrizQuadrata] = "Friz Quadrata",
    [C.Style.Fonts.FrizQuadrataCyrillic] = "Friz Quadrata (Cyrillic)",
    [C.Style.Fonts.ArialNarrow] = "Arial Narrow",
    [C.Style.Fonts.Morpheus] = "Morpheus",
    [C.Style.Fonts.Skurri] = "Skurri",
    [C.Style.Fonts.TwoThousandTwo] = "2002",
    [C.Style.Fonts.Expressway] = "Expressway",
    [C.Style.Fonts.Bazooka] = "Bazooka",
}

C.Colors = {
    Highlight = { r = 1, g = 0.8, b = 0, a = 1 },
    White = { r = 1, g = 1, b = 1, a = 1 },
    Gray = { r = 0.67, g = 0.67, b = 0.67, a = 1 },
    Danger = { r = 1, g = 0, b = 0, a = 1 },
}

C.Defaults = {
    AllowThresholdColorsByCategory = {
        [C.Categories.Actionbar] = true,
        [C.Categories.Nameplate] = false,
        [C.Categories.Unitframe] = true,
        [C.Categories.CooldownManager] = false,
        [C.Categories.MiniCC] = false,
        [C.Categories.SArena] = false,
        [C.Categories.TellMeWhen] = false,
        [C.Categories.CompactPartyAura] = true,
    },
    Category = {
        Font = C.Style.Fonts.GameDefault,
        FontSize = 18,
        FontStyle = C.Style.FontStyles.Outline,
        TextColor = C.Colors.Highlight,
        TextAnchor = C.Style.Anchors.Center,
        TextOffsetX = 0,
        TextOffsetY = 0,
        HideCountdownNumbers = false,
        AuraCdTextOnlyMine = false,
        DrawSwipe = true,
        EdgeEnabled = true,
        EdgeScale = 1.4,
        StackEnabled = true,
        HideStackText = false,
        StackFont = C.Style.Fonts.GameDefault,
        StackSize = 16,
        StackStyle = C.Style.FontStyles.Outline,
        StackColor = C.Colors.White,
        StackAnchor = C.Style.Anchors.BottomRight,
        StackOffsetX = -3,
        StackOffsetY = 3,
    },
    Actionbar = {
        HideChargeTimers = true,
        SwipeAlpha = 80,
    },
    Nameplate = {
        FontSize = 12,
        StackSize = 8,
        StackAnchor = C.Style.Anchors.BottomRight,
        StackOffsetX = 0,
        StackOffsetY = 0,
    },
    Unitframe = {
        stackEnabled = false,
        StackSize = 10,
        StackAnchor = C.Style.Anchors.BottomRight,
        StackOffsetX = 0,
        StackOffsetY = 0,
    },
    CooldownManager = {
        EssentialFontSize = 18,
        UtilityFontSize = 18,
        BuffIconFontSize = 18,
    },
    MiniCC = {
        CCFontSize = 18,
        CCHideCountdownNumbers = false,
        NameplateFontSize = 12,
        NameplateHideCountdownNumbers = false,
        PortraitFontSize = 18,
        PortraitHideCountdownNumbers = false,
        OverlayFontSize = 18,
        OverlayHideCountdownNumbers = false,
    },
    SArena = {
        ClassIconFontSize = 18,
        DRFontSize = 18,
        TrinketRacialFontSize = 18,
    },
    TellMeWhen = {
        FontSize = 18,
    },
    CompactPartyAuraText = {
        Enabled = true,
        RaidEnabled = false,
        Font = C.Style.Fonts.GameDefault,
        FontSize = 12,
        DefensiveBuffFontSize = 16,
        FontStyle = C.Style.FontStyles.Outline,
        TextColor = C.Colors.Highlight,
        TextAnchor = C.Style.Anchors.Center,
        TextOffsetX = 0,
        TextOffsetY = 0,
        DrawSwipe = true,
        EdgeEnabled = true,
        EdgeScale = 1.4,
        StackEnabled = false,
        HideStackText = false,
        StackFont = C.Style.Fonts.GameDefault,
        StackSize = 8,
        StackStyle = C.Style.FontStyles.Outline,
        StackColor = C.Colors.White,
        StackAnchor = C.Style.Anchors.BottomRight,
        StackOffsetX = 0,
        StackOffsetY = 0,
    },
    DurationTextColors = {
        Enabled = false,
        Offset = 0,
        Thresholds = {
            { threshold = 5, color = C.Colors.Danger },
            { threshold = 60, color = C.Colors.Highlight },
            { threshold = 300, color = C.Colors.White },
        },
        DefaultColor = C.Colors.Gray,
    },
}

C.Urls = {
    CurseForge = "https://www.curseforge.com/wow/addons/minice-cooldown-styler",
    Developer = "https://www.curseforge.com/members/anahkas/projects",
    MiniCC = "https://www.curseforge.com/wow/addons/minicc",
    TellMeWhen = "https://www.curseforge.com/wow/addons/tellmewhen",
    SmartPvPTabTargeting = "https://www.curseforge.com/wow/addons/pvp-tab-targeting",
}

C.Alerts = {
    VersionAlerts = {
        ["3.2.0"] = {
            updateLine = "|cff7dd3fcUpdate:|r CooldownManager viewers have their own dedicated category - style them with |cfffacc15/minice|r.",
        },
    },
}

C.ImportExport = {
    Prefix = "MCE1",
    Base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
    ImportPattern = "^(%w+):([CN]):(.+)$",
    CompressionMode = {
        Compressed = "C",
        None = "N",
    },
}

C.ImportExport.Base64Lookup = {}
for i = 1, #C.ImportExport.Base64Alphabet do
    local character = C.ImportExport.Base64Alphabet:sub(i, i)
    C.ImportExport.Base64Lookup[character] = i - 1
end

C.Classifier = {
    ScanDepth = 10,
    NameplateObjectType = "NamePlate",
    MiniCCNamePrefix = "MiniCC_",
    TellMeWhenNamePrefix = "TellMeWhen_",
    IgnoreActionbarPattern = "Aura",
    BlacklistNameContains = {
        "Glider", "VuhDo",
        "ElvUI", "ElvUF", "ElvNP", "elvnp", "Elv_", "ElvAB_", "Tukui",
        "Gw2_","GW2", "Gw2", "GW2_", "Gw_", "GW_", 
        "ArenaDrNP_"
    },
    BlacklistParentNames = {    
        "Tukui", "Glider", "VuhDo",
        "ElvUI", "ElvUF", "ElvNP", 
        "PVEFrame", "PVPQueueFrame",
        "LossOfControlFrame",
        "ContainerFrameCombinedBagsCooldown",
        "HousingDashboardFrame", "TotemFrame",
        "PlayerFrameBottomManagedFramesContainer",
        "CharacterBackSlot",
        "CharacterShirtSlot",
        "CharacterMainHandSlot",
        "CharacterLegsSlot",
        "CharacterFinger0Slot",
        "CharacterHeadSlot",
        "CharacterFeetSlot",
        "CharacterShoulderSlot",
        "CharacterWristSlot",
        "CharacterHandsSlot",
        "CharacterTabardSlot",
        "CharacterSecondaryHandSlot",
        "CharacterFinger1Slot",
        "CharacterWaistSlot",
        "CharacterChestSlot",
        "CharacterNeckSlot",
        "CharacterTrinket1Slot",
        "CharacterTrinket0Slot",
    },
    NameplatePatterns = { "nameplate", "plater", "kui", "threatplate" },
    UnitFramePatterns = {
        "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame",
        "SUF", "CompactPartyFrame", "CompactRaidFrame",
        "Grid", "Plexus", "Cell", "TPerl",
    },
    AuraButtonPatterns = { "BuffButton", "DebuffButton", "TempEnchant" },
    ActionbarPatterns = { "Action", "MultiBar", "BT4", "Dominos" },
    CooldownManagerViewerPatterns = {
        Essential = "EssentialCooldownViewer",
        Utility = "UtilityCooldownViewer",
        BuffIcon = "BuffIconCooldownViewer",
    },
}

C.Adapter = {
    ActionBars = {
        BlizzardFamilies = {
            { prefix = "ActionButton", count = 12 },
            { prefix = "MultiBarBottomLeftButton", count = 12 },
            { prefix = "MultiBarBottomRightButton", count = 12 },
            { prefix = "MultiBarRightButton", count = 12 },
            { prefix = "MultiBarLeftButton", count = 12 },
            { prefix = "MultiBar5Button", count = 12 },
            { prefix = "MultiBar6Button", count = 12 },
            { prefix = "MultiBar7Button", count = 12 },
        },
        ThirdPartyPrefixes = {
            "BT4Button",
            "DominosActionButton",
        },
        ThirdPartyMaxIndex = 180,
        CooldownKeys = { "cooldown", "Cooldown" },
        ChargeCooldownKeys = { "chargeCooldown", "ChargeCooldown" },
    },
    Nameplates = {
        MaxAncestorDepth = 4,
    },
    UnitFrames = {
        BlizzardRoots = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame" },
        ThirdPartyPatterns = { "SUF", "TPerl" },
        MaxAncestorDepth = 5,
    },
    GroupFrames = {
        PartyMemberPrefix = "CompactPartyFrameMember",
        PartyMemberCount = 5,
        RaidFramePrefix = "CompactRaidFrame",
        RaidFrameMaxCount = 40,
        MaxAncestorDepth = 8,
    },
    CooldownManager = {
        MaxAncestorDepth = 6,
    },
    MiniCC = {
        -- Hierarchy depth is fixed at 3 hops (Cooldown→Layer→Slot→Container)
        -- and resolved directly; no depth constants are needed here.
    },
    SArena = {
        MaxArenaOpponents = 5,
        MaxAncestorDepth = 4,
    },
    TellMeWhen = {
        DomainKeys = { "profile", "global" },
        CooldownNameFragment = "IconModule_CooldownSweepCooldown",
    },
    ShinyAuras = {
        RootFrameName = "ShinyAurasFrame",
        MaxScanDepth = 4,
    },
}

C.Styler = {
    CooldownLifecycleEvents = {
        OnShow = "OnShow",
        OnHide = "OnHide",
        OnDone = "OnCooldownDone",
    },
    CooldownMemberKeys = { "cooldown", "Cooldown", "chargeCooldown", "ChargeCooldown" },
    MaxCooldownOwnerScanDepth = 10,
    DefaultSwipeAlpha = 80,
    AlphaPercentMin = 0,
    AlphaPercentMax = 100,
    NumericComparisonEpsilon = 0.001,
    DurationCacheSweepThreshold = 10,
    DurationColorTickerInterval = 0.5,
    AuraRetryMinInterval = 0.25,
    StackTextLayer = C.Style.Layers.Overlay,
    StackTextSubLevel = 7,
}
