--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local LSM = LibStub("LibSharedMedia-3.0")

local defaults = {
    profile = {
        anchorPoint = "TOPRIGHT",
        xOffset = 0,
        yOffset = -280,
        width = 305,
        maxHeight = 600,
        frameScale = 1,
        frameStrata = "LOW",
        frameScrollbar = true,

        bgr = "Solid",
        bgrColor = { r = 0, g = 0, b = 0, a = 0 },
        border = "無",
        borderColor = KT.TRACKER_DEFAULT_COLOR,
        classBorder = false,
        borderAlpha = 1,
        borderThickness = 16,
        bgrInset = 4,
        progressBar = "Blizzard",

        font = LSM:GetDefault("font"),
        fontSize = 16,
        fontFlag = "",
        fontShadow = 1,
        colorDifficulty = false,
        textWordWrap = false,
        objNumSwitch = false,

        hdrBgr = 2,
        hdrBgrColor = KT.TRACKER_DEFAULT_COLOR,
        hdrBgrColorShare = false,
        hdrTxtColor = KT.TRACKER_DEFAULT_COLOR,
        hdrTxtColorShare = false,
        hdrBtnColor = KT.TRACKER_DEFAULT_COLOR,
        hdrBtnColorShare = false,
        hdrTrackerBgrShow = true,
        hdrCollapsedTxt = 2,
        hdrOtherButtons = true,

        qiBgrBorder = false,
        qiXOffset = -5,
        qiActiveButton = true,
        qiActiveButtonBindingShow = true,

        questLogShowDetails = true,

        messageQuest = true,
        messageAchievement = true,
        sink20OutputSink = "UIErrorsFrame",
        sink20Sticky = false,
        soundChannel = "Master",
        soundQuest = false,
        soundQuestComplete = "KT - Default",

        hideEmptyTracker = false,

        modulesOrder = KT.MODULES,

        tooltipShow = true,
        tooltipShowRewards = true,
        tooltipShowID = true,
        menuWowheadURL = true,
        menuWowheadURLModifier = "",
        menuYouTubeURL = true,
        menuYouTubeURLModifier = "",

        questsHeaderAppend = true,
        questsShowTags = true,
        questsShowZone = true,
        questsAutoFocusClosest = false,
        tasksShowFaction = true,
        achievsHeaderAppend = true,
        achievsProgressAutoTrack = true,
        scenarioEnemyForcesFormat = 1,

        addonAuctionator = false,
        addonBtWQuests = false,
        addonMasque = false,
        addonNarcissus = false,
        addonPetTracker = false,
        addonRareScanner = false,
        addonTomTom = false,
    },
    char = {
        collapsed = false,
        quests = {
            num = 0,
            favorites = {},
            cache = {}
        },
        achievements = {
            favorites = {}
        },
        waypoint = {
            mapID = 0,
            id = 0,
            type = nil,
            stype = nil
        }
    }
}

for cmd, int in pairs(KT.KEYBINDINGS) do
    if int then
        defaults.profile[cmd] = ""
    end
end

for _, ctx in ipairs(KT.VISIBILITY_CONTEXTS) do
    defaults.profile["visibility"..ctx] = "show"
end

function KT:Config_Init()
    self.db = LibStub("AceDB-3.0"):New(strsub(addonName, 2).."DB", defaults, true)
end