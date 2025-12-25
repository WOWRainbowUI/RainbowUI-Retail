--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("Menu")

local db

local function Menu_AddButton(_, info, type, id)
    if not db then return end

    if db.menuWowheadURL then
        if not info.KTmenuExtended then
            MSA_DropDownMenu_AddSeparator(info)
            info.KTmenuExtended = true
        end

        info.text = "|cff33ff99Wowhead|r URL"
        info.func = KT.Alert_WowheadURL
        info.arg1 = type
        info.arg2 = id
        info.notCheckable = true
        info.checked = false
        MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)
    end

    if db.menuYouTubeURL then
        if not info.KTmenuExtended then
            MSA_DropDownMenu_AddSeparator(info)
            info.KTmenuExtended = true
        end

        info.text = "|cff33ff99YouTube|r Search URL"
        info.func = KT.Alert_YouTubeURL
        info.arg1 = type
        info.arg2 = id
        info.notCheckable = true
        info.checked = false
        MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)
    end
end

function SS:Init()
    db = KT.db.profile

    KT:RegSignal("CONTEXT_MENU_UPDATE", Menu_AddButton, self)
end