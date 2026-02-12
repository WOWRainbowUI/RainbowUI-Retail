--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2026 - James N. Whitehead II
-------------------------------------------------------------------]]--

local addonName = select(1, ...)

--- @class CliqueAddon
local addon = select(2, ...)
local L = addon.L

addon.databaseDefaults = {
    char = {
        disableInHousing = true,
        blacklist = {},
        blizzframes = {
            -- Fix the health and mana bars
            statusBarFix = true,
            -- Remove the menu action from all Blizzard frames
            wipeMenuAction = false,

            -- Default frames enabled
            PlayerFrame = true,
            PetFrame = true,
            TargetFrame = true,
            TargetFrameToT = true,
            FocusFrame = true,
            FocusFrameToT = true,
            arena = true,
            party = true,
            compactraid = true,
            compactparty = true,
            boss = true,
        },
        stopcastingfix = false,
    },
    profile = {
        bindings = {
        },
    },
}

-- A new profile is being created in the db, called 'profile'
function addon:OnNewProfile(event, db, profile)
    table.insert(db.profile.bindings, {
        key = "BUTTON1",
        type = "target",
        unit = "mouseover",
        sets = {
            default = true
        },
    })

    table.insert(db.profile.bindings, {
        key = "BUTTON2",
        type = "menu",
        sets = {
            default = true
        },
    })
    self.bindings = db.profile.bindings
end

function addon:OnProfileChanged(event, db, newProfile)
    self.bindings = db.profile.bindings
    self:FireMessage("BINDINGS_CHANGED")
end

function addon:ImportBindings(importBindings)
    self.db.profile.bindings = importBindings
    self.bindings = self.db.profile.bindings
    self:Printf(L["Importing new bindings into current profile"])
    self:FireMessage("BINDINGS_CHANGED")
end
