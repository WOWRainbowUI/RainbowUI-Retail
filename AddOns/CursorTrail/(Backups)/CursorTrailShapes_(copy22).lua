--[[---------------------------------------------------------------------------
    File:   CursorTrailShapes.lua
    Desc:   This file contains a list of shapes used by this addon.
-----------------------------------------------------------------------------]]

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Aliases to Globals                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local Globals = _G
local _  -- Prevent tainting global _ .
local assert = _G.assert
local ipairs = _G.ipairs
local print = _G.print
local table = _G.table
local tonumber = _G.tonumber
local type = _G.type

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Declare Namespace                                 ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local CursorTrail = _G.CursorTrail or {}
if (not _G.CursorTrail) then _G.CursorTrail = CursorTrail end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Remap Global Environment                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setfenv(1, _G.CursorTrail)  -- Everything after this uses our namespace rather than _G.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Constants                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kDefaultShapeID = kMediaPath.."Cross 1.tga"
kShape_None = ""  -- Must not be nil.

kShapeConstants = {}
do -- Initialize kShapeConstants.
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    local addShape = function(displayName, shapeID, width, height, scale, texCoords)
        assert(displayName and displayName ~= "")
        assert(width and height) -- Width and height required!
        assert(scale == nil or type(scale) == "number")
        assert(texCoords == nil or type(texCoords) == "table")

        table.insert(kShapeConstants, {
                displayName = displayName,
                shapeID = shapeID,
                width = width,
                height = height,
                scale = scale or 1,
                texCoords = texCoords,
            })
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
    ----local colorChanger = { color = "",
    ----    next = function(self)
    ----        if self.color == "" then self.color = CatColor2 else self.color = "" end
    ----        return self.color
    ----    end,
    ----}
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

    local retail = isRetailWoW()
    local co = ""
    local size

    -- IMPORTANT!  Add lines in alphabetical order (by display name).
    --      -----------------------------   ---------------------------------------------------------
    --              DISPLAY NAME              SHAPE ID,  WIDTH,  HEIGHT, [ SCALE,  TEXTURE COORDS ]
    --      -----------------------------   ---------------------------------------------------------
    addShape(kStr_None,                     kShape_None, 0, 0)
    ----co = colorChanger:next()
    addShape(co.."Bug  (Blue)",             605711, 64, 64) -- "Interface\\HELPFRAME\\HelpIcon-Bug"
    addShape(co.."Bug  (Orange)",           2447131, 64, 64) -- "Interface\\HELPFRAME\\HelpIcon-Bug-Red"
    ----co = colorChanger:next()
    addShape(co.."Circle 1",                kMediaPath.."Circle 1.tga", 64, 64)
    addShape(co.."Circle 2",                kMediaPath.."Circle 2.tga", 64, 64)
    ----co = colorChanger:next()
    addShape(co.."Cross 1",                 kMediaPath.."Cross 1.tga", 64, 64)
    addShape(co.."Cross 2",                 kMediaPath.."Cross 2.tga", 64, 64)
    addShape(co.."Cross 3",                 kMediaPath.."Cross 3.tga", 64, 64)
    ----co = colorChanger:next()
    ----addShape(co.."Cursor  (Attack)",        342521, 64, 64) -- "Interface\\TUTORIALFRAME\\UI-TutorialFrame-AttackCursor"
    ----addShape(co.."Cursor  (Glove)",         344158, 64, 64) -- "Interface\\TUTORIALFRAME\\UI-TutorialFrame-GloveCursor"
    ----co = colorChanger:next()
    addShape(co.."Frame  (Gold)",           237701, 64, 64, 1, {.035, 1, .02, 1}) -- "Interface\\Vehicles\\UI-Vehicles-Button-Highlight"
    addShape(co.."Frame  (Gold, 3D)",       618870, 64, 64) -- "Interface\\SPELLBOOK\\RotationIconFrame"
  if retail then
    addShape(co.."Frame  (Stormy, Yellow)", 4861476, 256, 128, 1.7) -- "Interface\\ExtraButton\\stormyellow-extrabutton"
  end
    ----co = colorChanger:next()
    addShape(co.."Glow",                    kMediaPath.."Glow 1.tga", 256, 256, 1.1)
    addShape(co.."Glow  (Gold)",            607860, 256, 256, 1.5) -- "Interface\\Challenges\\challenges-metalglow"
    ----addShape(co.."Glow  (Green)",           131978, 256, 256, 1.3) -- "Interface\\GLUES\\Models\\UI_MainMenu_BurningCrusade\\glow_green"
    addShape(co.."Glow  (Reversed)",        kMediaPath.."Glow Reversed.tga", 64, 64, 1.01)
    ----addShape(co.."Glow  (Sunglare)",        1063368, 256, 256, 1.2) -- "Interface\\GLUES\\Models\\UI_Alliance\\UI_Troll_sunglare"
    ----addShape(co.."Glow  (Sunglare, Gold)",  1063478, 256, 256, 1.2) -- "Interface\\GLUES\\Models\\UI_Dwarf\\UI_Goblin_sunglare"
    ----co = colorChanger:next()
  size = retail and 1024 or 256
    addShape(co.."Glyph  (Green)",          136841, size, size, 1.5) -- "Interface\\SpellShadow\\Spell-Shadow-Acceptable"
    ----co = colorChanger:next()
    addShape(co.."Ring 1",                  kMediaPath.."Ring 1.tga", 64, 64)
    addShape(co.."Ring 1 (Soft)",           kMediaPath.."Ring Soft 1.tga", 64, 64)
    addShape(co.."Ring 2",                  kMediaPath.."Ring 2.tga", 64, 64)
    addShape(co.."Ring 2 (Soft)",           kMediaPath.."Ring Soft 2.tga", 64, 64)
    addShape(co.."Ring 3",                  kMediaPath.."Ring 3.tga", 64, 64)
    addShape(co.."Ring 3 (Soft)",           kMediaPath.."Ring Soft 3.tga", 64, 64)
    addShape(co.."Ring 4",                  kMediaPath.."Ring 4.tga", 64, 64)
    addShape(co.."Ring 4 (Soft)",           kMediaPath.."Ring Soft 4.tga", 64, 64)
    ----co = colorChanger:next()
    addShape(co.."Ring  (Arcane)",          "Interface\\UnitPowerBarAlt\\Arcane_Circular_Frame", 128, 128, 1.3) -- DO NOT CONVERT THIS PATH TO AN ID# !  (So current user profiles still work.)
    addShape(co.."Ring  (Atramedes)",       457566, 128, 128, 1.15, {.1, .9, .1, .9}) -- "Interface\\UnitPowerBarAlt\\Atramedes_Circular_Frame"
    addShape(co.."Ring  (Bronze)",          457594, 128, 128, 1.1, {.15, .85, .15, .85}) -- "Interface\\UnitPowerBarAlt\\MetalBronze_Circular_Frame"
  if retail then
    ----addShape(co.."Ring  (Brown)",           1949861, 512, 512, 0.95) -- "Interface\\Azerite\\AzeriteGoldRingRanks"
  end
    ----addShape(co.."Ring  (Brown, Split)",    237654, 128, 128, 1.05, {.119, .89, .135, .907}) -- "Interface\\SPELLBOOK\\UI-GlyphFrame-Locked"
    addShape(co.."Ring  (Eclipse)",         461873, 256, 256, 1.14, {0, .725, 0, .725}) -- "Interface\\TUTORIALFRAME\\minimap-glow"
    ----addShape(co.."Ring  (Eternium)",        457597, 128, 128, 1.12, {.15, .85, .15, .85}) -- "Interface\\UnitPowerBarAlt\\MetalEternium_Circular_Frame"
    addShape(co.."Ring  (Fire)",            "Interface\\UnitPowerBarAlt\\Fire_Circular_Frame", 128, 128, 1.4) -- DO NOT CONVERT THIS PATH TO AN ID# !  (So current user profiles still work.)
    addShape(co.."Ring  (Gear)",            457591, 128, 128, 1.25, {.019, .99, .025, 1}) -- "Interface\\UnitPowerBarAlt\\Mechanical_Circular_Frame"
    addShape(co.."Ring  (Gold)",            519888, 64, 64, 1.03) -- "Interface\\COMMON\\GoldRing"
  if retail then
    addShape(co.."Ring  (Gradient 1)",      4734120, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtMining"
    addShape(co.."Ring  (Gradient 2)",      4734108, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtLeatherworking"
    ----addShape(co.."Ring  (Gradient 2.2)",      4734131, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtSkinning"
    addShape(co.."Ring  (Gradient 3)",      4755699, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtEngineering"
    addShape(co.."Ring  (Gradient 4)",      4734100, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtBlacksmithing"
    addShape(co.."Ring  (Gradient 5)",      4734114, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtJewelcrafting"
    addShape(co.."Ring  (Gradient 6)",      4734106, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtAlchemy"
    addShape(co.."Ring  (Gradient 7)",      4734111, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtEnchanting"
    addShape(co.."Ring  (Gradient 8)",      4734097, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtTailoring"
    addShape(co.."Ring  (Gradient 9)",     4734118, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtHerbalism"
    addShape(co.."Ring  (Gradient 10)",     4734102, 128, 128, 1.03, {.123, .855, .13, .865}) -- "Interface\\Professions\\ProfessionSpecializationMiniDialArtInscription"
  end
    addShape(co.."Ring  (Horde)",           457585, 128, 128, 1.3, {.1, .9, .1, .9}) -- "Interface\\UnitPowerBarAlt\\Horde_Circular_Frame"
    addShape(co.."Ring  (Ice)",             458995, 128, 128, 1.3, {.1, .9, .1, .9}) -- "Interface\\UnitPowerBarAlt\\Ice_Circular_Frame"
    addShape(co.."Ring  (Meat)",            458999, 128, 128, 1.3, {.1, .9, .1, .9}) -- "Interface\\UnitPowerBarAlt\\Meat_Circular_Frame"
  if retail then
    ----addShape(co.."Ring  (Orange)",          2131913, 128, 128, 0.98, {.09, .91, .09, .91}) -- "Interface\\PVPFrame\\pvpqueue-sidebar-honorbar-fill"
  end
    addShape(co.."Ring  (Reticle)",         307587, 256, 256, 1.1, {.2, .8, .2, .8}) -- "Interface\\Vehicles\\Reticle2"
    addShape(co.."Ring  (Spotted)",         1117898, 128, 128, 0.95) -- "Interface\\MINIMAP\\UI-BonusObjectiveBlob-MinimapRing"
    addShape(co.."Ring  (Stone)",           449445, 128, 128, 1.03, {.18, .82, .18, .82}) -- "Interface\\UnitPowerBarAlt\\Generic1Player_Circular_Frame"
    addShape(co.."Ring  (Stone 2)",         457623, 128, 128, 1.03, {.17, .83, .17, .83}) -- "Interface\\UnitPowerBarAlt\\WowUI_Circular_Frame"
    ----co = colorChanger:next()
    addShape(co.."Shield  (Alliance)",      457561, 128, 128) -- "Interface\\UnitPowerBarAlt\\Alliance_Circular_Frame"
    addShape(co.."Shield  (Gold)",          607858, 256, 256) -- "Interface\\Challenges\\challenges-gold"
    ----co = colorChanger:next()
    addShape(co.."Sphere",                  kMediaPath.."Sphere Edge 2.tga", 128, 128)
    ----co = colorChanger:next()
    addShape(co.."Star",                    kMediaPath.."Star 1.tga", 64, 64)
    ----co = colorChanger:next()
    addShape(co.."Swirl",                   kMediaPath.."Swirl.tga", 256, 256)
    ----co = colorChanger:next()
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Functions                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
function getShapeData(shapeID)
    assert(shapeID)
    for i, data in ipairs(kShapeConstants) do
        if shapeID == data.shapeID then
            return data
        end
    end
end

-------------------------------------------------------------------------------
function ShapeDropDown_AddLines(dropdown)
    for i, data in ipairs(kShapeConstants) do
        dropdown:AddItem(data.displayName, data.shapeID or "")
    end
end

--~ -------------------------------------------------------------------------------
--~ -- (For Development - Dump numeric ID for built-in texture file names.)
--~ Globals.C_Timer.After(3, function()
--~     local color = "|cff00cccc"
--~     print(color.."CursorTrailShapes.lua: DUMPING SHAPE ID#s")
--~     local dropdown = private.UDControls.CreateDropDown(OptionsFrame)
--~     ShapeDropDown_AddLines(dropdown)
--~     local frm = Globals.CreateFrame("Frame", nil, UIParent)
--~     local tex = frm:CreateTexture()
--~     for i = 1, #dropdown.itemIDs do
--~         tex:SetTexture( dropdown.itemIDs[i] )
--~         print(color, tex:GetTextureFileID(), "=", dropdown.items[i])
--~     end
--~     tex:SetTexture(nil); tex=nil; frm=nil; dropdown=nil
--~ end)

--- End of File ---