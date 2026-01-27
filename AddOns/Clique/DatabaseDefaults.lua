--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2024 - James N. Whitehead II
-------------------------------------------------------------------]] ---

---@class CliqueAddon
local addon = select(2, ...)

addon.defaults = {
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
