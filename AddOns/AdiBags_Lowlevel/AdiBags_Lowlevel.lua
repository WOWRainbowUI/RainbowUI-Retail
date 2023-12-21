--[[
AdiBags_Lowlevel - Adds Lowlevel filters to AdiBags.
Copyright 2016 seirl
All rights reserved.
--]]

local _, ns = ...

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})
L['Lowlevel'] = "低等級"
L['Low level'] = "低等級"
L['Put Low level items in their own sections.'] = "把低等級的物品放在一個區塊裡。"
L['Enable Lowlevel'] = "啟用低等級"
L['Check this if you want a section for lowlevel items.'] = "將低等級的物品放在一起。"
L['Item level'] = "物品等級"
L['Minimum item level matched'] = "小於此數值為低等級"

-- The filter itself

local setFilter = addon:RegisterFilter("Lowlevel", 62, 'ABEvent-1.0')
setFilter.uiName = L['Lowlevel']
setFilter.uiDesc = L['Put Low level items in their own sections.']

function setFilter:OnInitialize()
  self.db = addon.db:RegisterNamespace('Lowlevel', {
    profile = { enable = true, level = 311 },
    char = {  },
  })
end

function setFilter:Update()
  self:SendMessage('AdiBags_FiltersChanged')
end

function setFilter:OnEnable()
  addon:UpdateFilters()
end

function setFilter:OnDisable()
  addon:UpdateFilters()
end

local setNames = {}

function setFilter:Filter(slotData)
  if not self.db.profile.enable or not slotData.equipSlot then
    return nil
  end
  
  local item = Item:CreateFromBagAndSlot(slotData.bag, slotData.slot)
  local itemLevel = item and item:GetCurrentItemLevel() or 0
  if itemLevel > 0 and slotData.equipSlot ~= "" and itemLevel < self.db.profile.level then
    return L["Low level"]
  end
  return nil
end

function setFilter:GetOptions()
  return {
    enable = {
      name = L['Enable Lowlevel'],
      desc = L['Check this if you want a section for lowlevel items.'],
      type = 'toggle',
      order = 10,
    },
    level = {
      name = L['Item level'],
      desc = L['Minimum item level matched'],
      type = 'range',
      min = 0,
      max = 1000,
      step = 1,
      order = 20,
    },
  }, addon:GetOptionHandler(self, false, function() return self:Update() end)
end