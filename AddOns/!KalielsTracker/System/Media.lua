--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local LSM = LibStub("LibSharedMedia-3.0")

local media = {
    -- Textures
    { type = "BORDER",      name = "Border",        filePath = KT.MEDIA_PATH.."KT-border" },
    { type = "STATUSBAR",   name = "Flat",          filePath = KT.MEDIA_PATH.."KT-statusbar-flat" },
    -- Sounds (Blizzard)
    { type = "SOUND",       name = "Default",       filePath = 558132 },    -- PeonBuildingComplete1.ogg
    { type = "SOUND",       name = "BloodElf (M)",  filePath = 539400 },    -- BloodElfMaleCongratulations02.ogg
    { type = "SOUND",       name = "BloodElf (F)",  filePath = 539175 },    -- BloodElfFemaleCongratulations03.ogg
    { type = "SOUND",       name = "Draenei (M)",   filePath = 539661 },    -- DraeneiMaleCongratulations02.ogg
    { type = "SOUND",       name = "Draenei (F)",   filePath = 539676 },    -- DraeneiFemaleCongratulations03.ogg
    { type = "SOUND",       name = "Dwarf (M)",     filePath = 540042 },    -- DwarfMaleCongratulations04.ogg
    { type = "SOUND",       name = "Dwarf (F)",     filePath = 539981 },    -- DwarfFemaleCongratulations01.ogg
    { type = "SOUND",       name = "Gnome (M)",     filePath = 540512 },    -- GnomeMaleCongratulations03.ogg
    { type = "SOUND",       name = "Gnome (F)",     filePath = 540432 },    -- GnomeFemaleCongratulations01.ogg
    { type = "SOUND",       name = "Goblin (M)",    filePath = 542005 },    -- VO_PCGoblinMale_Congratulations01.ogg
    { type = "SOUND",       name = "Goblin (F)",    filePath = 541735 },    -- VO_PCGoblinFemale_Congratulations01.ogg
    { type = "SOUND",       name = "Human (M)",     filePath = 540703 },    -- HumanMaleCongratulations01.ogg
    { type = "SOUND",       name = "Human (F)",     filePath = 540654 },    -- HumanFemaleCongratulations01.ogg
    { type = "SOUND",       name = "NightElf (M)",  filePath = 541085 },    -- NightElfMaleCongratulations01.ogg
    { type = "SOUND",       name = "NightElf (F)",  filePath = 541031 },    -- NightElfFemaleCongratulations02.ogg
    { type = "SOUND",       name = "Orc (M)",       filePath = 541401 },    -- OrcMaleCongratulations02.ogg
    { type = "SOUND",       name = "Orc (F)",       filePath = 541317 },    -- OrcFemaleCongratulations01.ogg
    { type = "SOUND",       name = "Pandaren (M)",  filePath = 630070 },    -- VO_PCPandarenMale_Congratulations02.ogg
    { type = "SOUND",       name = "Pandaren (F)",  filePath = 636419 },    -- VO_PCPandarenFemale_Congratulations02.ogg
    { type = "SOUND",       name = "Tauren (M)",    filePath = 561484 },    -- TaurenYes3.ogg
    { type = "SOUND",       name = "Tauren (F)",    filePath = 542997 },    -- TaurenFemaleCongratulations01.ogg
    { type = "SOUND",       name = "Troll (M)",     filePath = 543307 },    -- TrollMaleCongratulations01.ogg
    { type = "SOUND",       name = "Troll (F)",     filePath = 543273 },    -- TrollFemaleCongratulations01.ogg
    { type = "SOUND",       name = "Undead (M)",    filePath = 542775 },    -- UndeadMaleCongratulations02.ogg
    { type = "SOUND",       name = "Undead (F)",    filePath = 542684 },    -- UndeadFemaleCongratulations01.ogg
    { type = "SOUND",       name = "Worgen (M)",    filePath = 542228 },    -- VO_PCWorgenMale_Congratulations01.ogg
    { type = "SOUND",       name = "Worgen (F)",    filePath = 542028 },    -- VO_PCWorgenFemale_Congratulations01.ogg
}

for _, item in ipairs(media) do
    LSM:Register(LSM.MediaType[item.type], "KT - "..item.name, item.filePath)
end

-- ---------------------------------------------------------------------------------------------------------------------

local atlas = {
    background1 = { file = KT.MEDIA_PATH.."KT-HeaderBackground-1", w = 512, h = 64 },
    background2 = { file = KT.MEDIA_PATH.."KT-HeaderBackground-2", w = 16, h = 64 },
    background3 = { file = KT.MEDIA_PATH.."KT-HeaderBackground-3", w = 16, h = 64 },
    arrows = { file = KT.MEDIA_PATH.."KT-Arrows", w = 16, h = 32 },
}

local sprites = {
    ["tracker-header-bgr-1"] = { atlas = atlas.background1, w = 298, h = 29, x = 4, y = 4 },
    ["tracker-header-bgr-2"] = { atlas = atlas.background2, w = 16, h = 29, x = 0, y = 4 },
    ["tracker-header-bgr-3"] = { atlas = atlas.background3, w = 16, h = 29, x = 0, y = 4 },
    ["module-header-bgr-1"] = { atlas = atlas.background1, w = 298, h = 24, x = 4, y = 37 },
    ["module-header-bgr-2"] = { atlas = atlas.background2, w = 16, h = 24, x = 0, y = 37 },
    ["module-header-bgr-3"] = { atlas = atlas.background3, w = 16, h = 24, x = 0, y = 37 },
    ["arrow-left"] = { atlas = atlas.arrows, w = 8, h = 21, x = 0, y = 0 },
    ["arrow-right"] = { atlas = atlas.arrows, w = 8, h = 21, x = 8, y = 0 },
}

function KT.SetSprite(texture, name, setSize)
    local s = sprites[name]
    if not s then return end
    local a = s.atlas
    if not a then return end

    local l = s.x / a.w
    local r = (s.x + s.w) / a.w
    local t = s.y / a.h
    local b = (s.y + s.h) / a.h

    texture:SetTexture(a.file)
    texture:SetTexCoord(l, r, t, b)
    if setSize then
        texture:SetSize(s.w, s.h)
    end
end

-- ---------------------------------------------------------------------------------------------------------------------

local UI_ICONS = {
    Alert = { texture = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew", size = 36, offsetX = 8, offsetY = -2 },
    MouseLeft = { atlas = "newplayertutorial-icon-mouse-leftbutton", width = 24, height = 28, offsetX = -1, offsetY = 6 },
    MouseRight = { atlas = "newplayertutorial-icon-mouse-rightbutton", width = 24, height = 28, offsetX = -1, offsetY = 6 }
}
KT.BuildIconMarkup(UI_ICONS)

function KT.GetUiIcon(name, key)
    if key then
        return UI_ICONS[name] and UI_ICONS[name][key]
    else
        return UI_ICONS[name]
    end
end

local POI_ICONS = {
    Quest = { atlas = "QuestNormal", size = 18 },
    QuestTurnin = { atlas = "QuestTurnin", size = 18 },
    WorldQuest = { atlas = "worldquest-icon", size = 18, offsetX = -3 },
    BonusObjective = { atlas = "Bonus-Objective-Star", size = 18, offsetX = -3 },
    TaxiNode = { atlas = "TaxiNode_Neutral", size = 18, offsetX = -3 },
    DigSite = { atlas = "ArchBlob", size = 18, offsetX = -3 },
    Dungeon = { atlas = "questlog-questtypeicon-dungeon", size = 18, offsetX = -3 },
    Raid = { atlas = "questlog-questtypeicon-raid", size = 18, offsetX = -3 },
    Delve = { atlas = "ui-hud-minimap-guildbanner-delves-large", size = 18, offsetX = -3 },
    Event = { atlas = "UI-EventPoi-Horn-big", size = 18, offsetX = -3 },
    MapPin = { atlas = "Waypoint-MapPin-Tracked", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Important] = { atlas = "questlog-questtypeicon-important", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Legendary] = { atlas = "questlog-questtypeicon-legendary", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Campaign] = { atlas = "Quest-Campaign-Available", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Calling] = { atlas = "Quest-DailyCampaign-Available", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Meta] = { atlas = "questlog-questtypeicon-Wrapper", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Recurring] = { atlas = "questlog-questtypeicon-Recurring", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Questline] = { atlas = "questlog-storylineicon", size = 18, offsetX = -3 },
    ["Quest"..Enum.QuestClassification.Normal] = { atlas = "QuestNormal", size = 18 },
    ["Housing"..Enum.HousingPlotOwnerType.None] = { atlas = "housing-map-plot-unoccupied", size = 18, offsetX = -3 },
    ["Housing"..Enum.HousingPlotOwnerType.Stranger] = { atlas = "housing-map-plot-occupied", size = 18, offsetX = -3 },
    ["Housing"..Enum.HousingPlotOwnerType.Friend] = { atlas = "housing-map-plot-occupied-friend", size = 18, offsetX = -3 },
    ["Housing"..Enum.HousingPlotOwnerType.Self] = { atlas = "housing-map-plot-player-house", size = 20, offsetX = -3 },
}
local POI_ICONS_OVERRIDES = {}
local POI_ICONS_RULES = {
    ["^delves%-"] = "Delve",
    ["^ui%-eventpoi%-"] = "Event",
}
setmetatable(POI_ICONS, {
    __index = function(self, key)
        if not key then return nil end

        local lkey = key:lower()

        local mapped = POI_ICONS_OVERRIDES[key]
        if mapped then
            return rawget(self, mapped)
        end

        for pattern, replace in pairs(POI_ICONS_RULES) do
            if lkey:match(pattern:lower()) then
                return rawget(self, replace)
            end
        end

        return rawget(self, key)
    end
})
KT.BuildIconMarkup(POI_ICONS)

function KT.GetPoiIcon(name, key)
    if key then
        return POI_ICONS[name] and POI_ICONS[name][key]
    else
        return POI_ICONS[name]
    end
end