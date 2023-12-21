--[[
AdiBags_Bound - Adds BoE/BoA filters to AdiBags.
Copyright 2010-2012 Kevin (kevin@outroot.com)
All rights reserved.
--]]

local _, ns = ...

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})

L["Bound"] = "綁定類型"
L["Put BOE/BOA in their own sections."] = "把帳號綁定和裝備綁定的物品放在各自的區塊裡。"
L["BoE"] = "裝備綁定"
L["BoA"] = "帳號綁定"
L['Enable BoE'] = "啟用裝備綁定"
L['Check this if you want a section for BoE items.'] = "將裝備綁定的物品放在一起。"
L['Enable BoA'] = "啟用帳號綁定"
L['Check this if you want a section for BoA items.'] = "將帳號綁定的物品放在一起。"

-- The filter itself

local setFilter = addon:RegisterFilter("Bound", 69, 'ABEvent-1.0')
setFilter.uiName = L['Bound']
setFilter.uiDesc = L['Put BOE/BOA in their own sections.']

function setFilter:OnInitialize()
  self.db = addon.db:RegisterNamespace('Bound', {
    profile = { enableBoE = true, enableBoA = true },
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

function setFilter:Filter(slotData)
  local tooltipData = C_TooltipInfo.GetBagItem(slotData.bag, slotData.slot)
  if not tooltipData then return end -- 暫時修正
	TooltipUtil.SurfaceArgs(tooltipData)

	for _, line in ipairs(tooltipData.lines) do
		TooltipUtil.SurfaceArgs(line)
	end

  for i = 2,3 do
    if tooltipData.lines[i] then
      local t = tooltipData.lines[i].leftText
      if self.db.profile.enableBoE and t == ITEM_BIND_ON_EQUIP then
        return L["BoE"]
      elseif self.db.profile.enableBoA and (t == ITEM_ACCOUNTBOUND or t == ITEM_BIND_TO_BNETACCOUNT or t == ITEM_BNETACCOUNTBOUND) then
        return L["BoA"]
      end
    end
  end
end

function setFilter:GetOptions()
  return {
    enableBoE = {
      name = L['Enable BoE'],
      desc = L['Check this if you want a section for BoE items.'],
      type = 'toggle',
      order = 10,
    },
    enableBoA = {
      name = L['Enable BoA'],
      desc = L['Check this if you want a section for BoA items.'],
      type = 'toggle',
      order = 20,
    },
  }, addon:GetOptionHandler(self, false, function() return self:Update() end)
end
