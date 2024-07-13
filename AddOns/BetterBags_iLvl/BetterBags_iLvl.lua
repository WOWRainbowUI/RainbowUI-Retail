---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, "BetterBags_iLvl requires BetterBags")

local addonName, root = ...;

---@class BetterBags_iLvl: AceModule
local addon = LibStub("AceAddon-3.0"):NewAddon(root, addonName, 'AceHook-3.0')

---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')

local L = root.L;
local _G = _G

-- Default values
local defaultThreshold = "460"

if (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC) then
    defaultThreshold = "60"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC) then
    defaultThreshold = "120"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC) then
    defaultThreshold = "225"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC) then
    defaultThreshold = "308"
end

function addon:OnInitialize()
    if type(BetterBags_iLvlDB) ~= "table" then
        BetterBags_iLvlDB = {}
        BetterBags_iLvlDB.defaultThreshold = defaultThreshold
        BetterBags_iLvlDB.threshold = defaultThreshold
        BetterBags_iLvlDB.includeJunk = true
    else
        BetterBags_iLvlDB.defaultThreshold = defaultThreshold
    end
end

categories:CreateCategory(L["CATEGORY_NAME"])
