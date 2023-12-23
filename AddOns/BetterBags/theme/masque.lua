local addonName = ... ---@type string

---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class MasqueTheme: AceModule
---@field groups table<string, MasqueGroup>
local masque = addon:NewModule('Masque')

---@class Masque: AceAddon
local Masque = LibStub('Masque', true)

---@class Localization: AceModule
local L = addon:GetModule('Localization')

function masque:OnEnable()
  if not Masque then
    return
  end
  self.groups = {}
  self.groups["Backpack"] = Masque:Group(L:G('BetterBags'), L:G('Backpack'))
  self.groups["Bank"] = Masque:Group(L:G('BetterBags'), L:G('Bank'))
end

function masque:AddButtonToGroup(group, button)
  if not Masque then
    return
  end
  self.groups[group]:AddButton(button)
end

function masque:RemoveButtonFromGroup(group, button)
  if not Masque then
    return
  end
  if group == nil then
    return
  end
  self.groups[group]:RemoveButton(button)
end