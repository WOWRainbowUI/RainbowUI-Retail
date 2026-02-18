--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("Menu")

local _info
local db

local function ExtendContextMenu(_, info, arg1, arg2, arg3)
    if not db then return end

    if db.menuWowheadURL then
        if not info.KTmenuExtended then
            KT.Menu_AddSeparator()
            info.KTmenuExtended = true
        end

        KT.Menu_AddButton("|cff33ff99Wowhead|r URL", KT.Alert_WowheadURL, arg1, arg2, arg3)
    end

    if db.menuYouTubeURL then
        if not info.KTmenuExtended then
            KT.Menu_AddSeparator()
            info.KTmenuExtended = true
        end

        KT.Menu_AddButton("|cff33ff99YouTube|r Search URL", KT.Alert_YouTubeURL, arg1, arg2, arg3)
    end
end

-- func, ?, ?, ?, boolean
local function Parse5Args(a, b, c, d, e)
    local func, arg1, arg2, arg3, disabled

    if type(e) == "boolean" then
        disabled = e
    elseif type(d) == "boolean" then
        disabled = d
        d = nil
    elseif type(c) == "boolean" then
        disabled = c
        c, d = nil, nil
    elseif type(b) == "boolean" then
        disabled = b
        b, c, d = nil, nil, nil
    elseif type(a) == "boolean" then
        disabled = a
        a, b, c = nil, nil, nil
    end

    if type(a) == "function" then
        func = a
        arg1 = b
        arg2 = c
        arg3 = d
    else
        arg1 = a
        arg2 = b
        arg3 = c
    end

    return func, arg1, arg2, arg3, disabled
end

-- func, boolean
local function Parse2Args(a, b)
    local func, disabled

    if type(b) == "boolean" then
        disabled = b
    elseif type(a) == "boolean" then
        disabled = a
    end

    if type(a) == "function" then
        func = a
    end

    return func, disabled
end

function KT.Menu_CreateInfo()
    _info = MSA_DropDownMenu_CreateInfo()
    _info.notCheckable = true
    _info.isNotRadio = true
    return _info
end

function KT.Menu_AddTitle(text)
    local info = {
        text = text,
        isTitle = true,
        notCheckable = true
    }
    MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL)
end

function KT.Menu_AddSeparator()
    MSA_DropDownMenu_AddSeparator(MSA_DROPDOWNMENU_MENU_LEVEL)
    _info.notCheckable = true
    _info.isNotRadio = true
end

function KT.Menu_AddButton(text, ...)
    local func, arg1, arg2, arg3, disabled = Parse5Args(...)
    _info.text = text
    if arg1 ~= nil then
        _info.arg1 = arg1
    end
    if arg2 ~= nil then
        _info.arg2 = arg2
    end
    if arg3 ~= nil then
        _info.arg3 = arg3
    end
    if disabled ~= nil then
        _info.disabled = disabled
    end
    if func ~= nil then
        _info.func = func
    end
    MSA_DropDownMenu_AddButton(_info, MSA_DROPDOWNMENU_MENU_LEVEL)
end

function KT.Menu_AddCheck(text, state, ...)
    local func, arg1, arg2, arg3, disabled = Parse5Args(...)
    _info.text = text
    if type(state) == "table" then
        local tbl, key, expected = unpack(state)
        if expected == nil then
            _info.checked = function()
                return tbl[key]
            end
        else
            _info.checked = function()
                return (tbl[key] == expected)
            end
        end
    else
        _info.checked = function()
            return state
        end
    end
    if arg1 ~= nil then
        _info.arg1 = arg1
    end
    if arg2 ~= nil then
        _info.arg2 = arg2
    end
    if arg3 ~= nil then
        _info.arg3 = arg3
    end
    if disabled ~= nil then
        _info.disabled = disabled
    end
    if func ~= nil then
        _info.func = func
    end
    MSA_DropDownMenu_AddButton(_info, MSA_DROPDOWNMENU_MENU_LEVEL)
end

function KT.Menu_AddRadio(text, state, value, ...)
    local func, disabled = Parse2Args(...)
    _info.text = text
    local tbl, key = unpack(state)
    _info.checked = function()
        return (tbl[key] == value)
    end
    _info.arg1 = value
    if disabled ~= nil then
        _info.disabled = disabled
    end
    if func ~= nil then
        _info.func = func
    end
    MSA_DropDownMenu_AddButton(_info, MSA_DROPDOWNMENU_MENU_LEVEL)
end

function SS:Init()
    db = KT.db.profile

    KT:RegSignal("CONTEXT_MENU_UPDATE", ExtendContextMenu, self)
end