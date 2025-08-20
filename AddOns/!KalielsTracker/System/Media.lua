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
}

local sprites = {
    ["tracker-header-bgr-1"] = { atlas = atlas.background1, w = 298, h = 29, x = 4, y = 4 },
    ["tracker-header-bgr-2"] = { atlas = atlas.background2, w = 16, h = 29, x = 0, y = 4 },
    ["tracker-header-bgr-3"] = { atlas = atlas.background3, w = 16, h = 29, x = 0, y = 4 },
    ["module-header-bgr-1"] = { atlas = atlas.background1, w = 298, h = 24, x = 4, y = 37 },
    ["module-header-bgr-2"] = { atlas = atlas.background2, w = 16, h = 24, x = 0, y = 37 },
    ["module-header-bgr-3"] = { atlas = atlas.background3, w = 16, h = 24, x = 0, y = 37 },
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