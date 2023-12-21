-- AdiBags_Keystone -- M+ keystone filter for AdiBags
-- Copyright (C) 2019-2023 Bryna Tinkspring
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local mod = AdiBags:RegisterFilter("Keystone", 91, "ABEvent-1.0")
mod.uiName = "M+ 鑰石";
mod.uiDesc = "將傳奇鑰石放到它自己的區塊裡。"

local texts = {}

local dungeonMap = {
  -- Dragonflight Season 1
  [399] = "晶紅",  -- Ruby Life Pools
  [400] = "諾庫德",   -- Nokhud Offensive
  [401] = "蒼藍",   -- Azure Vault
  [402] = "學院",   -- Algethar Academy
  [210] = "眾星",  -- Court of Stars
  [200] = "英靈",  -- Halls of Valor
  [165] = "影月",  -- Shadowmoon Burial Grounds
  [2]   = "玉蛟寺",  -- Temple of the Jade Serpent

  -- Dragonflight Season 2
  [438] = "尖塔",   -- Vortex Pinnacle
  [206] = "奈穴", -- Neltharion's Lair
  [245] = "自由",   -- Freehold
  [251] = "幽腐", -- Underrot
  [403] = "奧達曼",  -- Uldaman: Legacy of Tyr
  [404] = "奈堡",   -- Neltharus
  [405] = "蕨皮",   -- Brackenhide Hollow
  [406] = "灌注",  -- Halls of Infusion
  
  -- Dragonflight Season 3
  [463] = "殞命地", -- Dawn of the Infinites: Galakrond's Fall
  [464] = "高地", -- Dawn of the Infinites: Murozond's Rise
  [244] = "阿塔", -- Atal'Dazar
  [248] = "莊園", -- Waycrest Manor
  [198] = "暗心", -- Darkheart Thicket
  [199] = "玄鴉堡", -- Black Rook Hold
  [168] = "永茂林", -- Everbloom
  [456] = "王座", -- Throne of the Tides
}

local function CreateTexts(button)
  local level = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightOutline")
  level:SetPoint("TOPLEFT", button, 3, -1)
  level:Hide()
  texts[button]["level"] = level

  local dungeon = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  dungeon:SetPoint("BOTTOM", button, 0, 0)
  dungeon:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
  dungeon:Hide()
  texts[button]["dungeon"] = dungeon
end

local function isKeystone(itemId)
  return itemId and itemId == 180653
end

function mod:OnEnable()
  self:RegisterEvent("BAG_UPDATE_DELAYED")
  self:RegisterMessage("AdiBags_UpdateButton", "UpdateButton")
  self:SendMessage("AdiBags_UpdateAllButtons")
end

function mod:BAG_UPDATE_DELAYED(event)
  self:SendMessage("AdiBags_UpdateAllButtons", true)
end

function mod:onDisable()
  for _, btext in pairs(texts) do
    for _, text in pairs(btext) do
      text:Hide()
    end
  end
end

function mod:UpdateButton(event, button)
  local id = button:GetItemId()

  if not isKeystone(id) then
    if texts[button] then
      for _, t in pairs(texts[button]) do
        t:Hide()
      end
    end
    return
  end

  local link = button:GetItemLink()
  if not texts[button] then
    texts[button] = {}
  end
  if not texts[button]["level"] then
    CreateTexts(button)
  end

  local keyInfo = {strsplit(':', link)}
  local keyDungeonId = tonumber(keyInfo[3])
  local keyLevel = tonumber(keyInfo[4])
  local dungeon = dungeonMap[keyDungeonId]

  texts[button]["level"]:SetText(keyLevel)
  texts[button]["level"]:Show()
  texts[button]["dungeon"]:SetText(dungeon)
  texts[button]["dungeon"]:Show()
end

function mod:Filter(slotData)
  if isKeystone(slotData.itemId) then
    return "鑰石"
  end
end
