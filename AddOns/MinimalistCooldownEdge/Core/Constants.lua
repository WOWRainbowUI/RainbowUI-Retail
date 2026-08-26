local addonName, addon = ...
local addonPath = "Interface\\AddOns\\" .. addonName

addon.Constants = addon.Constants or {}
local C = addon.Constants

C.Addon = {
    Name = addonName,
    AceName = "MinimalistCooldownEdge",
    ShortName = "MiniCE",
    SavedVariables = "MinimalistCooldownEdgeDB_v2",
    CooldownManagerCenteredName = "CooldownManagerCentered",
    HealerCCName = "HealerCC",
    MiniAurasName = "MiniAuras",
    DominosName = "Dominos",
    DominosCastName = "Dominos_Cast",
    DominosConfigName = "Dominos_Config",
    Bartender4Name = "Bartender4",
    SArenaName = "sArena_Reloaded",
    TellMeWhenName = "TellMeWhen",
    MyDRsName = "MyDRs",
    ShackledName = "Shackled",
    ShinyAurasName = "ShinyAuras",
    MUIName = "mUI",
    BetterBlizzFramesName = "BetterBlizzFrames",
    BetterBlizzPlatesName = "BetterBlizzPlates",
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
    PlayerAura = "playeraura",
    CooldownManager = "cooldownmanager",
    HealerCC = "healercc",
    MiniAuras = "miniauras",
    MyDRs = "mydrs",
    SArena = "sarena",
    TellMeWhen = "tellmewhen",
    Shackled = "shackled",
    PartyRaidRetired = "partyRaidRetired",
}

C.CooldownManagerViewers = {
    Essential = "essential",
    Utility = "utility",
    BuffIcon = "bufficon",
}

C.PlayerAuraTypes = {
    Buff = "buff",
    Debuff = "debuff",
    ExternalDefensiveBuffs = "externalDefensiveBuffs",
}

C.MiniAurasFrameTypes = {
    CC = "cc",
    RaidFrameAura = "raidframeaura",
    Portrait = "portrait",
    Overlay = "overlay",
    -- MiniAuras retains these displays only on its pre-12.1 backend.
    LegacyEnemyCD = "enemycd",
    LegacyFriendlyCD = "friendlycd",
}

C.SArenaFrameTypes = {
    ClassIcon = "classicon",
    DR = "dr",
    Trinket = "trinket",
    Racial = "racial",
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
    DefaultMillisecondsThreshold = 0,
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
        Top = "TOP",
        Bottom = "BOTTOM",
        Left = "LEFT",
        Right = "RIGHT",
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
        [C.Categories.Unitframe] = true,
        [C.Categories.PlayerAura] = false,
        [C.Categories.CooldownManager] = false,
        [C.Categories.HealerCC] = false,
        [C.Categories.SArena] = false,
        [C.Categories.TellMeWhen] = false,
        [C.Categories.MyDRs] = false,
        [C.Categories.Shackled] = false,
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
        ReverseSwipe = false,
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
        -- Visibility of auras cast by other players on target/focus. MiniCE owns
        -- the aura container on 12.1, so Blizzard's own "only my debuffs" option
        -- no longer applies; these mirror its historical default.
        OnlyMineDebuffs = true,
        OnlyMineBuffs = false,
        -- Blizzard anchors the Target/Focus spell bar under its own aura
        -- container, which MiniCE suppresses. Re-anchor it below the MiniCE
        -- aura rows so it stops overlapping them.
        CastBarReposition = true,
    },
    PlayerAura = {
        DisableFading = false,
        ReverseSwipe = true,
        SwipeAlpha = 80,
        TimerInsideIcon = false,
    },
    CooldownManager = {
        EssentialFontSize = 18,
        UtilityFontSize = 18,
        BuffIconFontSize = 18,
        EssentialStackSize = 16,
        UtilityStackSize = 16,
        BuffIconStackSize = 16,
        AuraColorEnabled = true,
        AuraColor = C.Colors.Highlight,
    },
    MiniAuras = {
        CCFontSize = 18,
        CCHideCountdownNumbers = false,
        CCHideSwipe = false,
        RaidFrameAuraFontSize = 18,
        RaidFrameAuraHideCountdownNumbers = false,
        RaidFrameAuraHideSwipe = false,
        PortraitFontSize = 18,
        PortraitHideCountdownNumbers = false,
        PortraitHideSwipe = false,
        OverlayFontSize = 18,
        OverlayHideCountdownNumbers = false,
        OverlayHideSwipe = false,
        SwipeAlpha = 80,
    },
    MyDRs = {
        FontSize = 16,
        -- MyDRs paints its own swipe at full opacity by default, so this
        -- matches its native look until the slider is changed.
        SwipeAlpha = 100,
        -- Matches MyDRs' own enableCooldownReverse default until the toggle
        -- is changed.
        ReverseSwipe = true,
    },
    SArena = {
        ClassIconFontSize = 18,
        DRFontSize = 18,
        TrinketRacialFontSize = 18,
    },
    TellMeWhen = {
        FontSize = 18,
    },
    Shackled = {
        FontSize = 18,
        -- Shackled paints its swipe with Blizzard's default CooldownFrameTemplate
        -- values (no custom shade/direction), so these match the addon's own
        -- Actionbar-style re-theme defaults rather than mirroring a native look.
        SwipeAlpha = 80,
        ReverseSwipe = false,
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
    MiniAuras = "https://www.curseforge.com/wow/addons/minicc",
    RaidFrameAuras = "https://www.curseforge.com/wow/addons/raid-party-frame-auras",
    ArenaDRNameplates = "https://www.curseforge.com/wow/addons/arena-dr-nameplates",
    TellMeWhen = "https://www.curseforge.com/wow/addons/tellmewhen",
    SmartPvPTabTargeting = "https://www.curseforge.com/wow/addons/pvp-tab-targeting",
}

C.ImportExport = {
    Prefix = "MCE1",
    ImportPattern = "^(%w+):([CN]):(.+)$",
    CompressionMode = {
        Compressed = "C",
        None = "N",
    },
}

C.Classifier = {
    ScanDepth = 10,
    NameplateObjectType = "NamePlate",
    MiniAurasNamePrefix = "MiniAuras_",
    TellMeWhenNamePrefix = "TellMeWhen_",
    IgnoreActionbarPattern = "Aura",
    BlacklistNameContains = {
        "Glider", "VuhDo",
        "ElvUI", "ElvUF", "ElvNP", "elvnp", "Elv_", "ElvAB_", "Tukui",
        "Gw2_","GW2", "Gw2", "GW2_", "Gw_", "GW_",
        "ArenaDrNP_",
        "FloatingChatFrame", "ChatFrame",

        -- Blizzard UIs with cooldown widgets that MiniCE never styles
        "SpellFlyoutButton",
        "ContainerFrame",
        "MailItem",
        "SendMailAttachment",
        "OpenMailAttachmentButton",
        "OpenMailLetterButton",
        "OpenMailMoneyButton",
        "GuildBank",
        "VoidStorage",
        "ReagentBank",
        "CompactPartyFrame",
        "CompactRaidFrame",

        -- Dominos
        "Dominos",

        -- Bartender4
        "BT4", "Bartender4",

        -- Explicit addon blacklists
        "Platynator",
        "Masque", "Masque_Caith",
        "ShadowUF", "ShadowedUF", "SUF",
        "Cell",
        "AbilityTimeline",
        "BattleGroundEnemies",
        "MidnightDR", "MidnightDR_", "MDR_",
        "NaowhQOL_",
        "RaidFrameAuras",
        "RFA_",
        "TrGCD", "trgcd",

        -- EllesmereUI family
        "Ellesmere",
        "EUI_",
        "ERB_",
        "EABR_",

        -- Nameplate GCD Tracker
        "NGCDT",
    },
    BlacklistParentNames = {
        "Tukui", "Glider", "VuhDo",
        "ElvUI", "ElvUF", "ElvNP",
        "PVEFrame", "PVPQueueFrame",
        "LFDQueueFrameRandomCooldownFrame",
        "LossOfControlFrame",
        "ContainerFrameCombinedBagsCooldown",
        "HousingDashboardFrame", "TotemFrame",
        "PlayerFrameBottomManagedFramesContainer",

        -- Blizzard inventory / bank / mail roots
        "ContainerFrame1",
        "ContainerFrame2",
        "ContainerFrame3",
        "ContainerFrame4",
        "ContainerFrame5",
        "ContainerFrame6",
        "ContainerFrameCombinedBags",
        "BankFrame",
        "BankPanel",
        "ReagentBankFrame",
        "GuildBankFrame",
        "VoidStorageFrame",
        "MailFrame",

        -- Blizzard inspect paper doll slots
        "InspectPaperDollFrame",
        "InspectBackSlot",
        "InspectChestSlot",
        "InspectFeetSlot",
        "InspectFinger0Slot",
        "InspectFinger1Slot",
        "InspectHandsSlot",
        "InspectHeadSlot",
        "InspectLegsSlot",
        "InspectMainHandSlot",
        "InspectNeckSlot",
        "InspectSecondaryHandSlot",
        "InspectShoulderSlot",
        "InspectShirtSlot",
        "InspectTabardSlot",
        "InspectTrinket0Slot",
        "InspectTrinket1Slot",
        "InspectWaistSlot",
        "InspectWristSlot",

        -- Explicit addon roots / containers
        "LibDBIcon10_Masque",
        "SUFWrapperFrame",
        "CellParent",
        "CellMainFrame",
        "CellAnchorFrame",
        "CellMenuFrame",
        "CellOptionsFrame",
        "CellTooltip",
        "AbilityTimelineBigIconFrame",
        "AtSpellIconSettingsFrame",
        "BattleGroundEnemies",
        "BGEAllies",
        "BGEEnemies",
        "MidnightDR",
        "MidnightDRFrame",
        "NaowhQOL_Dragonriding",
        "NaowhQOL_MovementAlert",
        "TrGCDBLScroll",
        "TrGCDItemBLScroll",
        "TrGCDActiveProfileSelect",
        "TrGCDframeConfirmDelete",

        -- EllesmereUI containers / roots
        "EllesmereUIFrame",
        "EllesmereUnlockMode",
        "EllesmereUIPartyModeFrame",
        "EllesmereUICursorFrame",
        "EUI_QuestTrackerFrame",
        "EllesmereUIResourceBarsFrame",
        "ERB_CastBarFrame",
        "ERB_SecondaryFrame",
        "EABR_Reminders",
        "EABR_Anchor",
        "EABR_CombatAnchor",
        "EABR_CursorAnchor",
        "EABR_TalentAnchor",
        "EABR_BeaconAnchor",
        "EllesmereUIUnitFrames_Player",
        "EllesmereUIUnitFrames_Target",
        "EllesmereUIUnitFrames_Focus",
        "EllesmereUIUnitFrames_Pet",
        "EllesmereUIUnitFrames_TargetTarget",
        "EllesmereUIUnitFrames_FocusTarget",
        "EllesmereUIUnitFrames_Boss1",
        "EllesmereUIUnitFrames_Boss2",
        "EllesmereUIUnitFrames_Boss3",
        "EllesmereUIUnitFrames_Boss4",
        "EllesmereUIUnitFrames_Boss5",
        "EllesmereUIUnitFrames_Boss6",
        "EllesmereUIUnitFrames_Boss7",
        "EllesmereUIUnitFrames_Boss8",

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
        ThirdPartyPrefixes = {},
        ThirdPartyMaxIndex = 180,
        CooldownKeys = { "cooldown", "Cooldown" },
        ChargeCooldownKeys = { "chargeCooldown", "ChargeCooldown" },
    },
    Bartender4 = {
        AddonName = "Bartender4",
        ButtonPrefix = "BT4Button",
        MaxButtonIndex = 180,
    },
    Dominos = {
        ButtonPrefixes = {
            "DominosActionButton",
            "MultiBarRightActionButton",
            "MultiBarLeftActionButton",
            "MultiBarBottomRightActionButton",
            "MultiBarBottomLeftActionButton",
            "MultiBar5ActionButton",
            "MultiBar6ActionButton",
            "MultiBar7ActionButton",
        },
        MaxAncestorDepth = 4,
    },
    Nameplates = {
        MaxAncestorDepth = 4,
    },
    UnitFrames = {
        BlizzardRoots = { "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame" },
        ThirdPartyPatterns = { "SUF", "TPerl" },
        MaxAncestorDepth = 5,
    },
    CooldownManager = {
        MaxAncestorDepth = 6,
    },
    HealerCC = {
        ContainerDepth = 3,
        FriendlyAnchorName = "HealerCCAnchor",
        EnemyAnchorName = "HealerCCEnemyAnchor",
        FriendlyContainerPattern = "^HealerCCIcon%d+Container$",
        EnemyContainerPattern = "^HealerCCEnemyIcon%d+Container$",
        FriendlyCooldownPattern = "^HealerCCIcon%d+Cooldown$",
        EnemyCooldownPattern = "^HealerCCEnemyIcon%d+Cooldown$",
    },
    MiniAuras = {
        -- MiniAuras uses both IconSlotContainer and AuraContainerDisplay
        -- hierarchies; the adapter resolves their named container ancestors.
        MaxNamedFrameID = 20000,
        TrailingNamedFrameMissLimit = 128,
        -- MiniAuras keeps thousands of pooled cooldowns alive, so discovery
        -- resumes across frames instead of resolving every named frame in a
        -- single script call: each pass probes this many names and claims at
        -- most this many previously unknown cooldowns.
        DiscoveryProbesPerPass = 4000,
        DiscoveryClaimsPerPass = 150,
        -- MiniAuras paints its swipes at this alpha when it creates the
        -- cooldown (both display backends) and never re-applies it. MiniCE
        -- restores this exact value when it releases the frame, so a disabled
        -- category never leaves the swipe at Blizzard's opaque default.
        NativeSwipeAlpha = 0.8,
    },
    MyDRs = {
        -- MyDRs names every DR icon button and hangs its cooldown on it.
        ContainerName = "MyDRsContainer",
        IconButtonPrefix = "MyDRsIconTracker",
        IconButtonPattern = "^MyDRsIconTracker%d+$",
        MaxIconIndex = 12,
    },
    SArena = {
        MaxArenaOpponents = 5,
        MaxAncestorDepth = 4,
    },
    TellMeWhen = {
        DomainKeys = { "profile", "global" },
        CooldownNameFragment = "IconModule_CooldownSweepCooldown",
    },
    Shackled = {
        -- Shackled's icon pool is anonymous (CreateFrame("Frame", nil, bar)); the
        -- only stable identity is the globally named bar frame every icon is a
        -- direct child of.
        BarFrameName = "ShackledBar",
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
    -- Hard ceiling on distinct end-time buckets held by the duration object
    -- cache. Long future cooldowns can outlive the duration color ticker, so
    -- the cache must bound itself instead of relying on ticker-driven cleanup.
    DurationCacheMaxEntries = 400,
    DurationColorTickerInterval = 0.5,
    AuraRetryMinInterval = 0.25,
    -- Minimum delay between full player-aura refreshes triggered by a
    -- UNIT_AURA payload whose unit token is secret (WoW 12.1). Such payloads
    -- fire for every group member and nameplate, so the refresh is throttled
    -- rather than coalesced per frame.
    SecretAuraRefreshInterval = 0.25,
    CooldownTextLayer = C.Style.Layers.Overlay,
    CooldownTextSubLevel = 7,
    ActionbarTextFrameLevelOffset = 1,
    StackTextLayer = C.Style.Layers.Overlay,
    StackTextSubLevel = 7,
}
