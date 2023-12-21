local _, ns = ...

local addon = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local L = setmetatable({}, {__index = addon.L})

L['Pawn'] = "升級裝備"
L['Put items upgrade in their own sections.'] = "把有升級箭頭的裝備放在一起。"
 
local setPawnsFilter = addon:RegisterFilter("Pawn", 93, 'ABEvent-1.0')
setPawnsFilter.uiName = L['Pawn']
setPawnsFilter.uiDesc = L['Put items upgrade in their own sections.']

function setPawnsFilter:OnInitialize()
    self.db = addon.db:RegisterNamespace('Pawn', {
        profile = { enable = true },
        char = {  },
    })
end

function setPawnsFilter:OnEnable()
    addon:UpdateFilters()
end

function setPawnsFilter:OnDisable()
    addon:UpdateFilters()
end

function setPawnsFilter:Filter(slotData)
	local itemIsUpgrade = _G.PawnIsContainerItemAnUpgrade(slotData.bag, slotData.slot)
    if self.db.profile.enable and itemIsUpgrade then
        return L["Pawn"]
    end
end
